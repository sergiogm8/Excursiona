import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/constants/assets.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  BitmapDescriptor _currentLocationIcon = BitmapDescriptor.defaultMarker;
  Position? _currentPosition;
  ExcursionController _excursionController = ExcursionController();
  var _finishedLocation = false;
  var _geoServiceEnabled;
  bool _initializedMarkers = false;
  var _isDragging = false;
  Set<UserModel> _participants = {};
  Map<String, dynamic> _usersMarkers = {};
  static const double _zoom = 20;
  static const double _tilt = 30;

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) positionStream!.cancel();
  }

  @override
  void initState() {
    _setCustomMarkerIcon();
    _retrieveParticipantsData();
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
        _currentPosition = position;
      });
      _shareCurrentLocation(_currentPosition!);
    });
    _captureWidgets();
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
                // myLocationEnabled: true,
                mapType: MapType.satellite,
              );
            }),
        Positioned(
            bottom: 30,
            left: 10,
            child: FloatingActionButton.small(
              onPressed: () async {
                _isDragging = false;
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        zoom: _zoom),
                  ),
                );
              },
              backgroundColor: Constants.indigoDye,
              tooltip: "Centrar en mi ubicación",
              child: const Icon(
                Icons.gps_fixed,
                // size: 40,
              ),
            )),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _initializedMarkers ? _buildMap() : _buildLoading());
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
                        // backgroundColor: Colors.white,
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
