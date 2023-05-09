import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:excursiona/constants/assets.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/pages/share_image_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/add_marker_dialog.dart';
import 'package:excursiona/widgets/change_map_type_button.dart';
import 'package:excursiona/widgets/drawer_item.dart';
import 'package:excursiona/widgets/icon_marker.dart';
import 'package:excursiona/widgets/marker_info_sheet.dart';
import 'package:excursiona/widgets/user_marker.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:screenshot/screenshot.dart';

class ExcursionPage extends StatefulWidget {
  const ExcursionPage(
      {super.key, required this.excursionId, this.participants});

  final String excursionId;
  final Set<UserModel>? participants;

  @override
  State<ExcursionPage> createState() => _ExcursionPageState();
}

class _ExcursionPageState extends State<ExcursionPage> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(38.9842, -3.9275), zoom: 5);

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  StreamSubscription<Position>? positionStream;

  static const double _tilt = 30;
  static const double _zoom = 20;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double _currentDistance = 0.0;
  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _warningMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _restMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _customMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _interestMarkerIcon = BitmapDescriptor.defaultMarker;
  Position? _currentPosition;
  double _currentSpeed = 0.0;
  Timer? _durationTimer;
  ExcursionController _excursionController = ExcursionController();
  var _finishedLocation = false;
  var _geoServiceEnabled;
  bool _initializedMarkers = false;
  var _isDragging = false;
  bool _isPlaying = false;
  var _mapType = MapType.satellite;
  Set<UserModel> _participants = {};
  Position? _previousPosition;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final DateTime _startTime = DateTime.now();
  Duration _timeElapsed = Duration.zero;
  Map<String, dynamic> _usersMarkers = {};

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) positionStream!.cancel();
    if (_durationTimer != null) _durationTimer!.cancel();
  }

  @override
  void initState() {
    _setCustomMarkerIcon();
    _retrieveParticipantsData();
    _initializeDurationTimer();
    loadData();
    super.initState();
  }

  loadData() {
    getCurrentPosition().then((value) async {
      _shareCurrentLocation(value);

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: _zoom);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      _finishedLocation = true;
      setState(() {
        _currentPosition = value;
      });
    }).catchError((error) {
      showSnackBar(context, Theme.of(context).primaryColor, error.toString());
      _finishedLocation = true;
    });
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('La ubicación no está activada');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permisos de ubicación denegados permanentemente, no se pueden solicitar los permisos.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Stream<List<MarkerModel>> getMarkers() {
    return _excursionController.getMarkers(widget.excursionId);
  }

  Set<Marker> updateMarkers(AsyncSnapshot snapshot) {
    Set<Marker> markers = {};
    if (snapshot.hasData) {
      List<MarkerModel> markersData = snapshot.data;
      markersData.forEach((MarkerModel markerModel) {
        final markerId = MarkerId(markerModel.id);
        if (markerModel.markerType == MarkerType.participant) {
          Marker marker = Marker(
              markerId: markerId,
              position: LatLng(markerModel.position.latitude,
                  markerModel.position.longitude),
              icon: AuthController().isCurrentUser(uid: markerModel.id)
                  ? _currentLocationIcon
                  : BitmapDescriptor.fromBytes(_usersMarkers[markerModel.id]),
              zIndex:
                  AuthController().isCurrentUser(uid: markerModel.id) ? 2 : 1);
          markers.add(marker);
        } else {
          var icon = _getBitmapByMarkerType(markerModel.markerType);
          Marker marker = Marker(
            markerId: markerId,
            position: LatLng(
                markerModel.position.latitude, markerModel.position.longitude),
            icon: icon,
            onTap: () => _showMarkerInfo(markerModel),
          );

          markers.add(marker);
        }
      });
    }
    return markers;
  }

  _showMarkerInfo(MarkerModel markerModel) {
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.2),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.35,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        elevation: 1,
        context: context,
        builder: (context) {
          return MarkerInfoSheet(markerModel: markerModel);
        });
  }

  _getBitmapByMarkerType(MarkerType markerType) {
    switch (markerType) {
      case MarkerType.info:
        return _interestMarkerIcon;
      case MarkerType.rest:
        return _restMarkerIcon;
      case MarkerType.warning:
        return _warningMarkerIcon;
      case MarkerType.custom:
        return _customMarkerIcon;
      default:
        return _interestMarkerIcon;
    }
  }

  _initializeDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _timeElapsed = DateTime.now().difference(_startTime);
      });
    });
  }

  _setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, Assets.resourceImagesMylocationicon)
        .then((value) {
      setState(() {
        _currentLocationIcon = value;
      });
    });
  }

  _retrieveParticipantsData() {
    if (widget.participants == null) {
      _excursionController
          .getParticipantsData(widget.excursionId)
          .then((participants) {
        setState(() {
          _participants = participants.toSet();
        });
      });
    } else {
      setState(() {
        _participants = widget.participants!;
      });
    }
  }

  _shareCurrentLocation(Position coords) async {
    _excursionController.shareCurrentLocation(coords, widget.excursionId);
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.disabled) {
        _geoServiceEnabled = false;
        showSnackBar(context, Theme.of(context).primaryColor,
            'La ubicación no está activada');
      } else {
        _geoServiceEnabled = true;
        loadData();
      }
    });

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (!_isDragging) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position!.latitude, position.longitude),
            zoom: _zoom)));
      }
      setState(() {
        _previousPosition = _currentPosition;
        _currentPosition = position;
      });
      _shareCurrentLocation(_currentPosition!);
      _recalculateDistanceAndSpeed();
    });
    _captureWidgets();
  }

  _recalculateDistanceAndSpeed() {
    if (_previousPosition != null) {
      var distance = Geolocator.distanceBetween(
          _previousPosition!.latitude,
          _previousPosition!.longitude,
          _currentPosition!.latitude,
          _currentPosition!.longitude);
      double speed = _currentPosition!.speed; // m/s
      speed = speed * 3.6; // km/h
      setState(() {
        _currentDistance += distance / 1000;
        _currentSpeed = speed;
      });
    }
  }

  _buildMap() {
    return Stack(
      children: [
        StreamBuilder(
            stream: getMarkers(),
            builder: (context, snapshot) {
              return GoogleMap(
                initialCameraPosition: initialCameraPosition,
                markers: updateMarkers(snapshot),
                onMapCreated: (GoogleMapController controller) =>
                    _onMapCreated(controller),
                onTap: (LatLng? latLng) {
                  _isDragging = true;
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                mapType: _mapType,
              );
            }),
        Align(
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.small(
                    heroTag: 'mapType',
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    tooltip: "Cambiar tipo de mapa",
                    child: const Icon(
                      Icons.layers_rounded,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        backgroundColor: Constants.darkWhite,
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.20),
                        builder: (context) {
                          return _buildBottomSheet();
                        },
                      );
                    }),
                FloatingActionButton.small(
                  heroTag: 'centerPosition',
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  tooltip: "Centrar en mi ubicación",
                  child: const Icon(
                    Icons.gps_fixed,
                  ),
                  onPressed: () async {
                    _isDragging = false;
                    final GoogleMapController controller =
                        await _controller.future;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            zoom: _zoom),
                      ),
                    );
                  },
                ),
                FloatingActionButton.small(
                  heroTag: 'reloadImages',
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  tooltip: "Recargar imágenes de usuario",
                  child: const Icon(
                    Icons.refresh_rounded,
                  ),
                  onPressed: () => _captureWidgets(),
                ),
              ],
            )),
        Positioned(
          bottom: 16,
          right: 16,
          child: SpeedDial(
            heroTag: 'addMarker',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: MdiIcons.flagVariantPlusOutline,
            activeIcon: Icons.close,
            useRotationAnimation: true,
            children: [
              SpeedDialChild(
                child: const Icon(Constants.customMarkerIcon,
                    color: Constants.indigoDye, size: 30),
                label: Constants.customMarkerText,
                onTap: () =>
                    _showAddMarkerDialog(markerType: MarkerType.custom),
              ),
              SpeedDialChild(
                child: const Icon(Constants.interestMarkerIcon,
                    color: Constants.indigoDye, size: 30),
                label: Constants.interestMarkerText,
                onTap: () => _showAddMarkerDialog(markerType: MarkerType.info),
              ),
              SpeedDialChild(
                child: const Icon(Constants.warningMarkerIcon,
                    color: Constants.indigoDye, size: 30),
                label: Constants.warningMarkerText,
                onTap: () =>
                    _showAddMarkerDialog(markerType: MarkerType.warning),
              ),
              SpeedDialChild(
                child: const Icon(Constants.restMarkerIcon,
                    color: Constants.indigoDye, size: 30),
                label: Constants.restMarkerText,
                onTap: () => _showAddMarkerDialog(markerType: MarkerType.rest),
              )
            ],
          ),
        ),
        Positioned(
          top: 50,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'menu',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () {
              setState(() {
                _scaffoldKey.currentState!.openDrawer();
              });
            },
            child: Icon(Icons.menu_rounded),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(children: [
                      Text(
                        "Velocidad: ",
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${_currentSpeed.toStringAsFixed(2)} km/h",
                        style: GoogleFonts.inter(fontSize: 13),
                      )
                    ])),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(children: [
                      Text(
                        "Distancia: ",
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${_currentDistance.toStringAsFixed(2)} km",
                        style: GoogleFonts.inter(fontSize: 13),
                      )
                    ])),
              ),
            ],
          ),
        ),
        if (!_finishedLocation) const Geolocating(),
      ],
    );
  }

  _buildLoading() {
    while (_participants.isEmpty) {
      return const Loader();
    }

    _captureWidgets();

    setState(() {
      _initializedMarkers = true;
    });
  }

  _captureWidgets() {
    ScreenshotController screenshotController = ScreenshotController();

    for (var element in _participants) {
      if (!AuthController().isCurrentUser(uid: element.uid)) {
        screenshotController
            .captureFromWidget(UserMarker(user: element),
                delay: const Duration(milliseconds: 200))
            .then((image) {
          setState(() {
            _usersMarkers[element.uid] = image;
          });
        });
      }
    }

    screenshotController
        .captureFromWidget(const IconMarker(
            icon: Constants.warningMarkerIcon,
            color: Constants.warningMarkerColor))
        .then((image) => setState(() {
              _warningMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Warning marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: Constants.restMarkerIcon, color: Constants.restMarkerColor))
        .then((image) => setState(() {
              _restMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Rest marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: Constants.interestMarkerIcon,
            color: Constants.interestMarkerColor))
        .then((image) => setState(() {
              _interestMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Interest marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: Constants.customMarkerIcon,
            color: Constants.customMarkerColor))
        .then((image) => setState(() {
              _customMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Custom marker
  }

  void _changeMapType(MapType mapType) {
    setState(() {
      _mapType = mapType;
    });
    Navigator.pop(context);
  }

  _buildBottomSheet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Tipo de mapa",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.satellite,
                  icon: Icons.satellite_alt,
                  label: "Satélite"),
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.normal,
                  icon: Icons.map,
                  label: "Normal"),
              MapTypeButton(
                  selectedMapType: _mapType,
                  onTap: _changeMapType,
                  mapType: MapType.terrain,
                  icon: Icons.terrain,
                  label: "Terreno")
            ],
          ),
        ],
      ),
    );
  }

  _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              // padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: const Icon(Icons.arrow_back, size: 24),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${_timeElapsed.inHours.toString()}h ${(_timeElapsed.inMinutes % 60).toString()}min',
                              style: GoogleFonts.inter(
                                  fontSize: 36, fontWeight: FontWeight.w300)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Has recorrido: ",
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text("${_currentDistance.toStringAsFixed(2)} km",
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text("Velocidad: ",
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          Text("${_currentSpeed.toStringAsFixed(2)} km/h",
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                DrawerItem(
                    title: 'Añadir participante',
                    icon: Icons.person_add_outlined,
                    onTap: () {}),
                DrawerItem(
                    title: 'Compartir imagen',
                    icon: Icons.add_photo_alternate_outlined,
                    onTap: () {
                      nextScreen(context, ShareImagePage(),
                          PageTransitionType.rightToLeft);
                    }),
                DrawerItem(
                    title: 'Galería de imágenes',
                    icon: Icons.photo_library_outlined,
                    onTap: () {}),
                DrawerItem(
                    title: 'Sala de chat',
                    icon: Icons.forum_outlined,
                    onTap: () {}),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(Icons.exit_to_app_rounded, size: 26),
                  const SizedBox(width: 10),
                  Text("Abandonar excursión",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          title: const Text("Abandonar la excursión"),
                          content: const Text(
                              "¿Seguro que quieres abandonar la excursión?"),
                          actions: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.cancel)),
                            IconButton(
                              onPressed: () {
                                //TODO: This will redirect to the excursion statistics page
                                nextScreenReplace(context, const HomePage(),
                                    PageTransitionType.fade);
                              },
                              icon: const Icon(Icons.check),
                            ),
                          ]);
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  _showAddMarkerDialog({required MarkerType markerType}) {
    showDialog(
        context: context,
        builder: (context) {
          return AddMarkerDialog(
            markerType: markerType,
            currentPosition: _currentPosition!,
            excursionId: widget.excursionId,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: _buildDrawer(),
        body: _initializedMarkers ? _buildMap() : _buildLoading());
  }
}

class Geolocating extends StatelessWidget {
  const Geolocating({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 55),
        child: Container(
            height: 50,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(76, 130, 130, 130),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(1, 1), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Loader(),
                  SizedBox(width: 15),
                  Text("Geolocalizando...", style: TextStyle(fontSize: 16))
                ],
              ),
            )),
      ),
    );
  }
}
