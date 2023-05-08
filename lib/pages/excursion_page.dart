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
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
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

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

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
    _customInfoWindowController.dispose();
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
          var icon = _getIconByMarkerType(markerModel.markerType);
          Marker marker = Marker(
            markerId: markerId,
            position: LatLng(
                markerModel.position.latitude, markerModel.position.longitude),
            icon: icon,
            onTap: () => showModalBottomSheet(
                barrierColor: Colors.transparent,
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.3,
                    minWidth: MediaQuery.of(context).size.width),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                context: context,
                builder: (context) {
                  return Text("Ventana marcador");
                }),
            // onTap: _customInfoWindowController.addInfoWindow!(
            //   Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       Container(
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(15),
            //             color: Constants.darkWhite),
            //         height: 200,
            //         width: 300,
            //         margin: const EdgeInsets.only(bottom: 25),
            //         padding: const EdgeInsets.all(8),
            //         child: Column(
            //           children: [
            //             Expanded(
            //               child: Padding(
            //                 padding: const EdgeInsets.all(5.0),
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(15),
            //                   ),
            //                   child: markerModel.imageUrl!.isNotEmpty
            //                       ? GestureDetector(
            //                           onTap: () {}, //OPEN FULL SCREEN IMAGE
            //                           child: Stack(
            //                             children: [
            //                               CachedNetworkImage(
            //                                 imageUrl: markerModel.imageUrl!,
            //                                 fit: BoxFit.fill,
            //                               ),
            //                               Positioned(
            //                                   bottom: 4,
            //                                   right: 4,
            //                                   child: Icon(
            //                                       MdiIcons.arrowExpandAll,
            //                                       color: Constants.darkWhite))
            //                             ],
            //                           ),
            //                         )
            //                       : Container(
            //                           color: Colors.grey[300],
            //                           child: Column(
            //                             mainAxisAlignment:
            //                                 MainAxisAlignment.center,
            //                             children: [
            //                               Icon(
            //                                 Icons.image_not_supported_outlined,
            //                                 color: Colors.grey,
            //                                 size: 50,
            //                               ),
            //                               Text(
            //                                 'No hay imagen',
            //                                 style: TextStyle(
            //                                     color: Constants.darkWhite),
            //                               )
            //                             ],
            //                           )),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       const Align(
            //           alignment: Alignment.bottomCenter,
            //           child: Icon(
            //             Icons.arrow_drop_down_rounded,
            //             color: Constants.darkWhite,
            //             size: 46,
            //           )),
            //     ],
            //   ),
            //   LatLng(markerModel.position.latitude,
            //       markerModel.position.longitude),
            // ),
          );

          markers.add(marker);
        }
      });
    }
    return markers;
  }

  _getIconByMarkerType(MarkerType markerType) {
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
    _customInfoWindowController.googleMapController = controller;
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
                  _customInfoWindowController.hideInfoWindow!();
                },
                onCameraMove: (position) {
                  _customInfoWindowController.onCameraMove!();
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                mapType: _mapType,
              );
            }),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 200,
          width: 300,
          offset: 50,
        ),
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
                child: const Icon(MdiIcons.flagVariant,
                    color: Constants.indigoDye, size: 30),
                label: 'Pin Personalizado',
                onTap: () =>
                    _showAddMarkerDialog(markerType: MarkerType.custom),
              ),
              SpeedDialChild(
                child: const Icon(Icons.info,
                    color: Constants.indigoDye, size: 30),
                label: 'Punto de interés',
                onTap: () => _showAddMarkerDialog(markerType: MarkerType.info),
              ),
              SpeedDialChild(
                child: const Icon(Icons.warning_rounded,
                    color: Constants.indigoDye, size: 30),
                label: 'Zona peligrosa',
                onTap: () =>
                    _showAddMarkerDialog(markerType: MarkerType.warning),
              ),
              SpeedDialChild(
                child: const Icon(MdiIcons.bed,
                    color: Constants.indigoDye, size: 30),
                label: 'Zona de descanso',
                onTap: () => _showAddMarkerDialog(markerType: MarkerType.rest),
              )
            ],
          ),
        ),
        Positioned(
          top: 40,
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
            // crossAxisAlignment: CrossAxisAlignment.start,
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
            icon: Icons.warning_rounded, color: Constants.warningMarkerColor))
        .then((image) => setState(() {
              _warningMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Warning marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: MdiIcons.bed, color: Constants.restMarkerColor))
        .then((image) => setState(() {
              _restMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Rest marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: Icons.info_rounded, color: Constants.interestMarkerColor))
        .then((image) => setState(() {
              _interestMarkerIcon = BitmapDescriptor.fromBytes(image);
            })); // Interest marker
    screenshotController
        .captureFromWidget(const IconMarker(
            icon: MdiIcons.flagVariant, color: Constants.customMarkerColor))
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

class IconMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconMarker({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: DecoratedIcon(
                icon: Icon(icon, color: color, size: 46),
                decoration: IconDecoration(border: IconBorder(width: 2))),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedIcon(
                  icon: Icon(Icons.arrow_drop_down, color: color, size: 38),
                  decoration: IconDecoration(border: IconBorder(width: 2)))),
        ],
      ),
    );
  }
}

class AddMarkerDialog extends StatefulWidget {
  const AddMarkerDialog(
      {super.key,
      required this.markerType,
      required this.currentPosition,
      required this.excursionId});

  final Position currentPosition;
  final String excursionId;
  final MarkerType markerType;

  @override
  State<AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<AddMarkerDialog> {
  Color color = Constants.indigoDye;
  TextEditingController titleController = TextEditingController();

  bool _canEditCoords = false;
  final _formKey = GlobalKey<FormState>();
  IconData? _icon;
  File? _image;
  final _latKey = GlobalKey<FormFieldState>();
  final _lngKey = GlobalKey<FormFieldState>();
  String _markerTitle = "";
  String? _title;
  bool _uploadedSuccessfully = true;
  bool _uploadingMarker = false;
  bool _useDefaultCoords = true;

  @override
  void initState() {
    super.initState();
    switch (widget.markerType) {
      case MarkerType.info:
        _icon = Icons.info_rounded;
        _title = "punto de interés";
        break;

      case MarkerType.warning:
        _icon = Icons.warning_rounded;
        _title = "zona de peligro";
        break;

      case MarkerType.rest:
        _icon = MdiIcons.bed;
        _title = "zona de descanso";
        break;

      case MarkerType.custom:
        _icon = MdiIcons.flagVariant;
        _title = "pin personalizado";
        break;
      default:
        break;
    }
  }

  _addMarker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _uploadingMarker = true;
    });
    var uploaded;
    if (_image != null) {
      uploaded = await ExcursionController().uploadMarker(
          excursionId: widget.excursionId,
          title: _markerTitle,
          markerType: widget.markerType,
          position: widget.currentPosition,
          image: _image!);
    } else {
      uploaded = await ExcursionController().uploadMarker(
          excursionId: widget.excursionId,
          title: _markerTitle,
          markerType: widget.markerType,
          position: widget.currentPosition);
    }
    setState(() {
      _uploadingMarker = false;
    });
    if (uploaded) {
      Navigator.pop(context);
      showSnackBar(context, Colors.green, "Marcador compartido correctamente.");
    } else {
      setState(() {
        _uploadedSuccessfully = false;
      });
    }
  }

  _pickImage() {
    ImagePicker imagePicker = ImagePicker();
    imagePicker
        .pickImage(source: ImageSource.camera, imageQuality: 70)
        .then((value) {
      if (value != null) {
        setState(() {
          _image = File(value.path);
        });
        print(value.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Constants.darkWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Constants.darkWhite,
          ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
          child: _uploadingMarker
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Loader(),
                    const SizedBox(height: 20),
                    Text(
                      "Compartiendo ${_title}... ",
                      style: GoogleFonts.inter(fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(children: [
                          Icon(
                            _icon,
                            color: color,
                            size: 35,
                          ),
                          const SizedBox(width: 10),
                          Text("Compartir $_title",
                              style: GoogleFonts.inter(fontSize: 20)),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: titleController,
                        maxLength: 50,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Por favor ingrese un título";
                          }
                        },
                        onChanged: (value) => setState(() {
                          _markerTitle = value;
                        }),
                        decoration: blueTextInputDecoration.copyWith(
                          hintText: "Título*",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(15)),
                          errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(mainAxisSize: MainAxisSize.max, children: [
                        Flexible(
                          child: TextFormField(
                              key: _latKey,
                              keyboardType: TextInputType.number,
                              initialValue:
                                  widget.currentPosition.latitude.toString(),
                              enabled: _canEditCoords,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "Campo obligatorio";
                                }
                              },
                              decoration: blueTextInputDecoration.copyWith(
                                  labelText: "Latitud*",
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Constants.indigoDye),
                                      borderRadius: BorderRadius.circular(15)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(15)),
                                  filled: !_canEditCoords,
                                  fillColor: _canEditCoords
                                      ? Constants.darkWhite
                                      : Colors.grey[200]),
                              style: _canEditCoords
                                  ? TextStyle(color: Colors.black)
                                  : TextStyle(color: Constants.darkGrey)),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: TextFormField(
                            key: _lngKey,
                            keyboardType: TextInputType.number,
                            initialValue:
                                widget.currentPosition.longitude.toString(),
                            enabled: _canEditCoords,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return "Campo obligatorio";
                              }
                            },
                            decoration: blueTextInputDecoration.copyWith(
                                labelText: "Longitud*",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                    borderRadius: BorderRadius.circular(15)),
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(15)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Constants.indigoDye),
                                    borderRadius: BorderRadius.circular(15)),
                                filled: !_canEditCoords,
                                fillColor: _canEditCoords
                                    ? Constants.darkWhite
                                    : Colors.grey[200]),
                            style: _canEditCoords
                                ? TextStyle(color: Colors.black)
                                : TextStyle(color: Constants.darkGrey),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 15),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10,
                              width: 20,
                              child: Checkbox(
                                value: _useDefaultCoords,
                                onChanged: (value) {
                                  setState(() {
                                    _useDefaultCoords = value!;
                                    _canEditCoords = !value;
                                  });
                                  if (value == true) {
                                    _latKey.currentState!.reset();
                                    _lngKey.currentState!.reset();
                                  }
                                },
                                side: const BorderSide(
                                    color: Constants.indigoDye, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                                fillColor: MaterialStateProperty.all(
                                    Constants.indigoDye),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text("Usar coordenadas automáticas",
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w400))
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            onTap: () => _pickImage(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Constants.indigoDye)),
                              child: _image == null
                                  ? Center(
                                      child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          color: Constants.lapisLazuli,
                                          size: 50,
                                        ),
                                        Text(
                                          "Pulsa aquí para añadir una imagen a tu marcador",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ))
                                  : Image.file(
                                      _image!,
                                      // fit: BoxFit.fitHeight_title,
                                      alignment: Alignment.center,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              fixedSize: const Size(105, 30),
                              // side: const BorderSide(color: Colors.black, width: 1),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('Cancelar',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          ElevatedButton(
                            onPressed: () => _addMarker(),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              fixedSize: const Size(105, 30),
                              backgroundColor: Constants.indigoDye,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Aceptar',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (!_uploadedSuccessfully)
                        const Text(
                          "Hubo un error al compartir el marcador. Inténtalo de nuevo.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  final IconData icon;
  final Function onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Colors.black,
          ),
          minLeadingWidth: 0,
          title: Text(title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
          onTap: () => onTap(),
        ),
        Divider(
          color: Colors.grey,
          thickness: 0.5,
          endIndent: MediaQuery.of(context).size.width * 0.05,
          indent: MediaQuery.of(context).size.width * 0.05,
          height: 3,
        ),
      ],
    );
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

class MapTypeButton extends StatelessWidget {
  const MapTypeButton(
      {super.key,
      required this.selectedMapType,
      required this.onTap,
      required this.mapType,
      required this.icon,
      required this.label});

  final IconData icon;
  final String label;
  final MapType mapType;
  final Function onTap;
  final MapType selectedMapType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(mapType),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(
                color: selectedMapType == mapType
                    ? Constants.steelBlue
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: selectedMapType == mapType
                ? Constants.lapisLazuli
                : Colors.white),
        width: 85,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 30,
                color: selectedMapType == mapType ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: selectedMapType == mapType
                        ? Colors.white
                        : Colors.black),
              )
            ]),
      ),
    );
  }
}

class UserMarker extends StatelessWidget {
  const UserMarker({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Constants.darkWhite,
            ),
            child: user.profilePic.isEmpty
                ? MediaQuery(
                    data: new MediaQueryData(),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: AccountAvatar(radius: 25, name: user.name),
                    ),
                  )
                : MediaQuery(
                    data: new MediaQueryData(),
                    child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            CachedNetworkImageProvider(user.profilePic)),
                  ),
          ),
          const Align(
              alignment: Alignment.bottomCenter,
              child: Icon(Icons.arrow_drop_down,
                  color: Constants.darkWhite, size: 36)),
        ],
      ),
    );
  }
}
