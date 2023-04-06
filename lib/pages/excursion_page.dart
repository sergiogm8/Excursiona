import 'dart:async';

import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExcursionPage extends StatefulWidget {
  const ExcursionPage({super.key, required this.excursionId});

  final String excursionId;

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

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  StreamSubscription<Position>? positionStream;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Position? _currentPosition;
  ExcursionController _excursionController = ExcursionController();
  var _finishedLocation = false;
  var _geoServiceEnabled;
  var _isDragging = false;

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) positionStream!.cancel();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    getCurrentPosition().then((value) async {
      _shareCurrentLocation(value);
      const markerId = MarkerId('currentPos');
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(value.latitude, value.longitude),
      );
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 15);

      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      _finishedLocation = true;
      setState(() {
        _currentPosition = value;
        markers[markerId] = marker;
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
            target: LatLng(position!.latitude, position.longitude), zoom: 18)));
      }
      const markerId = MarkerId('currentPos');
      try {
        final marker = markers[markerId];
        Marker _marker = Marker(
          markerId: marker!.markerId,
          position: LatLng(position!.latitude, position.longitude),
        );
        setState(() {
          markers[markerId] = _marker;
          _currentPosition = position;
        });
        _shareCurrentLocation(_currentPosition!);
      } catch (e) {}
    });
  }

  Set<Marker> updateMarkers(snapshot) {
    Set<Marker> markers = {};
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
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
                mapType: MapType.satellite,
              );
            }),
        Positioned(
            bottom: 30,
            left: 10,
            child: FloatingActionButton.small(
              onPressed: () async {
                _shareCurrentLocation(_currentPosition!);
                _isDragging = false;
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        zoom: 18),
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
    ));
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
