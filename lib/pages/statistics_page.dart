import 'dart:io';

import 'package:banner_carousel/banner_carousel.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/model/route.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/gallery_page_widgets.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class StatisticsPage extends StatefulWidget {
  final Excursion excursion;
  final String? userId;
  final bool isNew;
  const StatisticsPage(
      {super.key, required this.excursion, this.userId, this.isNew = true});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Excursion get _excursion => widget.excursion;
  String get _excursionId => widget.excursion.id;
  String? get _userId => widget.userId;
  late ExcursionController _excursionController;
  RouteModel? _userRoute;
  StatisticRecap? _excursionData;
  bool _isLoading = true;
  final ScreenshotController _screenshotController = ScreenshotController();
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    _excursionController = ExcursionController(excursionId: _excursionId);
    _getExcursionData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  _getExcursionData() async {
    try {
      var userRoute = await _excursionController.getUserRoute(_userId);
      var excursionData = await _excursionController.getExcursionData(_userId);

      _userRoute = userRoute;
      _excursionData = excursionData;
    } on Exception catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
    setState(() {
      _isLoading = false;
    });
    if (widget.isNew) {
      _excursionController.updateUserStatistics(_excursionData!);
    }
  }

  LatLngBounds _getPolylineBounds(Polyline polyline) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (LatLng point in polyline.points) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }
      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }
      if (point.longitude < minLng) {
        minLng = point.longitude;
      }
      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    LatLng southwest = LatLng(minLat, minLng);
    LatLng northeast = LatLng(maxLat, maxLng);

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  _generateMarkers() async {
    Set<Marker> markers = {};
    var image = await _screenshotController.captureFromWidget(Container(
        padding: const EdgeInsets.all(4),
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        )));

    markers.add(Marker(
      markerId: const MarkerId('start'),
      position: _userRoute!.startPoint,
      icon: BitmapDescriptor.fromBytes(image),
      anchor: Offset(0.5, 0.5),
    ));
    markers.add(Marker(
      markerId: const MarkerId('end'),
      position: _userRoute!.endPoint,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    setState(() {
      _markers = markers;
    });
  }

  _buildBody() {
    Polyline polylineRoute = Polyline(
        polylineId: const PolylineId('route'),
        points: _userRoute!.route!
            .map((locationModel) => locationModel.position)
            .toList(),
        width: 4,
        color: Colors.lightBlue);
    CameraPosition cameraPosition = CameraPosition(
      target: _userRoute!.getMidPoint().position,
      zoom: 12,
    );
    LatLngBounds bounds = _getPolylineBounds(polylineRoute);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: GoogleMap(
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            compassEnabled: false,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            mapToolbarEnabled: false,
            onTap: (argument) => nextScreen(
              context,
              MapViewRecap(
                  route: polylineRoute,
                  initialCamera: cameraPosition,
                  bounds: bounds,
                  routeDelimiters: _markers,
                  excursionController: _excursionController),
              PageTransitionType.rightToLeft,
            ),
            markers: _markers,
            mapType: MapType.satellite,
            initialCameraPosition: cameraPosition,
            polylines: {polylineRoute},
            onMapCreated: (controller) async {
              _mapController = controller;
              await _generateMarkers();
              Future.delayed(const Duration(microseconds: 100));
              _mapController!
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
            },
          ),
        ),
        const SizedBox(height: 26),
        _excursionData == null
            ? const Loader()
            : Expanded(
                flex: 6,
                child: BannerCarousel(
                  activeColor: Constants.indigoDye,
                  showIndicator: true,
                  height: double.infinity,
                  customizedBanners: [
                    StatisticView(statistics: _excursionData!),
                    ImagesView(excursionController: _excursionController),
                    MarkersView(excursionController: _excursionController)
                  ],
                ),
              )
      ],
    );
  }

  _saveExcursion() {
    _mapController!.takeSnapshot().then((mapSnapshot) async {
      final tempDir = await getTemporaryDirectory();
      final snapshotFile = File('${tempDir.path}/map.png');
      await snapshotFile.writeAsBytes(mapSnapshot!);
      var userController = UserController();
      var currentUser = await userController.getUserBasicInfo();
      ExcursionRecap excursionRecap = ExcursionRecap(
        id: _excursionId,
        date: _excursion.date,
        duration: _excursionData!.duration,
        distance: _excursionData!.distance!,
        avgSpeed: _excursionData!.avgSpeed!,
        nParticipants: _excursionData!.nParticipants,
        title: _excursion.title,
        description: _excursion.description,
        difficulty: _excursion.difficulty,
        userId: currentUser.uid,
        userPic: currentUser.profilePic,
        userName: currentUser.name,
      );

      try {
        userController.saveExcursion(
          excursionRecap,
          snapshotFile,
        );
      } catch (e) {
        showSnackBar(context, Colors.red, e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de la excursión', style: GoogleFonts.inter()),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          widget.isNew
              ? IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    if (widget.isNew) {
                      await _saveExcursion();
                    }
                    nextScreenReplace(context, const HomePage(),
                        PageTransitionType.rightToLeft);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ],
      ),
      body: !_isLoading ? _buildBody() : const Center(child: Loader()),
    );
  }
}

class MarkersView extends StatelessWidget {
  final ExcursionController excursionController;
  const MarkersView({super.key, required this.excursionController});

  Stream<List<MarkerModel>> _getMarkers() {
    return excursionController.getMarkers().map((markerList) =>
        markerList.where((marker) => _isNotParticipant(marker)).toList());
  }

  _isNotParticipant(MarkerModel marker) {
    return marker.markerType != MarkerType.participant;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Marcadores creados",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: _getMarkers(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Loader();
                }
                if (snapshot.hasError) {
                  return const Text("Error al cargar los marcadores");
                }
                return snapshot.data != null && snapshot.data!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(children: [
                          for (var marker in snapshot.data!)
                            MarkerImageCard(marker: marker)
                        ]),
                      )
                    : const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "No hay marcadores para mostrar",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ImagesView extends StatelessWidget {
  final ExcursionController excursionController;
  const ImagesView({super.key, required this.excursionController});

  Stream<List<ImageModel>> _getImagesFromExcursion() {
    return excursionController.getImagesFromExcursion();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.only(bottom: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Imágenes compartidas",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: _getImagesFromExcursion(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Loader();
                }
                if (snapshot.hasError) {
                  return const Text("Error al cargar las imágenes");
                }
                return snapshot.data!.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.6),
                        itemBuilder: (context, index) {
                          return SharedImageCard(
                            data: snapshot.data![index],
                          );
                        },
                      )
                    : const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "No hay imágenes para mostrar",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticView extends StatelessWidget {
  final StatisticRecap statistics;
  const StatisticView({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen",
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                StatisticRow(
                  MdiIcons.timerPlay,
                  "Hora de inicio",
                  DateFormat('HH:mm').format(statistics.startTime),
                ),
                const Divider(),
                StatisticRow(
                  MdiIcons.timerPause,
                  "Hora de fin",
                  DateFormat('HH:mm').format(statistics.endTime),
                ),
                const Divider(),
                StatisticRow(MdiIcons.timelapse, "Duración",
                    '${statistics.duration.inHours.toString()}h ${(statistics.duration.inMinutes % 60).toString()}min'),
                const Divider(),
                StatisticRow(
                  MdiIcons.mapMarkerDistance,
                  "Distancia",
                  "${statistics.distance!.toStringAsFixed(2)} km",
                ),
                const Divider(),
                StatisticRow(
                  MdiIcons.runFast,
                  "Velocidad media",
                  "${statistics.avgSpeed!.toStringAsFixed(1)} km/h",
                ),
                const Divider(),
                StatisticRow(
                  MdiIcons.arrowUpDown,
                  "Altitud media",
                  "${statistics.avgAltitude!.toStringAsFixed(0)} m",
                ),
                const Divider(),
                StatisticRow(
                  Icons.group,
                  "Nº participantes",
                  statistics.nParticipants.toString(),
                ),
                const Divider(),
                StatisticRow(
                  Icons.photo_library,
                  "Imágenes en la galería",
                  statistics.nPhotos.toString(),
                ),
                const Divider(),
                StatisticRow(
                  MdiIcons.mapMarkerMultiple,
                  "Marcadores creados",
                  statistics.nMarkers.toString(),
                ),
                const Divider(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class StatisticRow extends StatelessWidget {
  const StatisticRow(this.icon, this.title, this.value, {super.key});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Constants.lapisLazuli),
            const SizedBox(width: 10),
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, fontSize: 16)),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(fontWeight: FontWeight.w300, fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class MapViewRecap extends StatefulWidget {
  final Polyline route;
  final CameraPosition initialCamera;
  final LatLngBounds bounds;
  final Set<Marker> routeDelimiters;
  final ExcursionController excursionController;
  const MapViewRecap(
      {super.key,
      required this.route,
      required this.initialCamera,
      required this.bounds,
      required this.routeDelimiters,
      required this.excursionController});

  @override
  State<MapViewRecap> createState() => _MapViewRecapState();
}

class _MapViewRecapState extends State<MapViewRecap> {
  Polyline get _route => widget.route;
  CameraPosition get _initialCamera => widget.initialCamera;
  LatLngBounds get _bounds => widget.bounds;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_back),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () => Navigator.pop(context)),
      body: GoogleMap(
        initialCameraPosition: _initialCamera,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        rotateGesturesEnabled: true,
        mapToolbarEnabled: false,
        polylines: {_route},
        markers: widget.routeDelimiters,
        mapType: MapType.satellite,
        onMapCreated: (controller) async {
          Future.delayed(const Duration(microseconds: 300));
          controller.animateCamera(CameraUpdate.newLatLngBounds(_bounds, 40));
        },
      ),
    );
  }
}
