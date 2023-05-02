import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/constants/assets.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/pages/share_image_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  bool _isPlaying = false;

  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
  Position? _currentPosition;
  Position? _previousPosition;
  double _currentSpeed = 0.0;
  double _currentDistance = 0.0;
  Duration _timeElapsed = Duration.zero;
  final DateTime _startTime = DateTime.now();
  Timer? _durationTimer;
  ExcursionController _excursionController = ExcursionController();
  var _finishedLocation = false;
  var _geoServiceEnabled;
  bool _initializedMarkers = false;
  var _isDragging = false;
  var _mapType = MapType.satellite;
  Set<UserModel> _participants = {};
  Map<String, dynamic> _usersMarkers = {};

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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

  _initializeDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _timeElapsed = DateTime.now().difference(_startTime);
      });
    });
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
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Stream<List<ExcursionParticipant>> getOthersLocation() {
    return _excursionController.getOthersLocation(widget.excursionId);
  }

  Set<Marker> updateMarkers(AsyncSnapshot snapshot) {
    Set<Marker> markers = {};
    if (snapshot.hasData) {
      List<ExcursionParticipant> participants = snapshot.data;
      participants.forEach((element) {
        final markerId = MarkerId(element.uid);
        Marker marker = Marker(
            markerId: markerId,
            position: LatLng(element.currentLocation.latitude,
                element.currentLocation.longitude),
            icon: AuthController().isCurrentUser(uid: element.uid)
                ? _currentLocationIcon
                : BitmapDescriptor.fromBytes(_usersMarkers[element.uid]),
            zIndex: AuthController().isCurrentUser(uid: element.uid) ? 2 : 1);
        markers.add(marker);
      });
    }
    return markers;
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
            stream: getOthersLocation(),
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
                child: const Icon(MdiIcons.flagVariant,
                    color: Constants.indigoDye, size: 30),
                label: 'Pin Personalizado',
              ),
              SpeedDialChild(
                child: const Icon(Icons.info,
                    color: Constants.indigoDye, size: 30),
                label: 'Punto de interés',
              ),
              SpeedDialChild(
                child: const Icon(Icons.warning_rounded,
                    color: Constants.indigoDye, size: 30),
                label: 'Zona peligrosa',
              ),
              SpeedDialChild(
                child: const Icon(MdiIcons.bed,
                    color: Constants.indigoDye, size: 30),
                label: 'Zona de descanso',
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
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(children: [
                      Text(
                        "Velocidad: ",
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${_currentSpeed.toStringAsFixed(2)} km/h",
                        style: GoogleFonts.inter(fontSize: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(children: [
                      Text(
                        "Distancia: ",
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${_currentDistance.toStringAsFixed(2)} km",
                        style: GoogleFonts.inter(fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        body: _initializedMarkers ? _buildMap() : _buildLoading());
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

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
