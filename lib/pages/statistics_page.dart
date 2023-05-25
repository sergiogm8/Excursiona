import 'package:banner_carousel/banner_carousel.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/route.dart';
import 'package:excursiona/model/statistic_recap.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/gallery_page_widgets.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:screenshot/screenshot.dart';

class StatisticsPage extends StatefulWidget {
  final String excursionId;
  const StatisticsPage({super.key, required this.excursionId});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String get _excursionId => widget.excursionId;
  late ExcursionController _excursionController;
  RouteModel? _userRoute;
  StatisticRecap? _excursionData;
  Uint8List? _mapImage;
  bool _isLoading = true;
  GoogleMapController? _mapController;
  ScreenshotController _screenshotController = ScreenshotController();
  // var _startPointMarker;
  Set<Marker> _markers = {};

  @override
  void initState() {
    _excursionController = ExcursionController(excursionId: _excursionId);
    _getExcursionData();
    super.initState();
  }

  _getExcursionData() async {
    var userRoute = await _excursionController.getUserRoute();
    var excursionData = await _excursionController.getExcursionData();

    _userRoute = userRoute;
    _excursionData = excursionData;
    setState(() {
      _isLoading = false;
    });
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

  Stream<List<ImageModel>> _getImagesFromExcursion() {
    return _excursionController.getImagesFromExcursion();
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
          child: GestureDetector(
            onTap: () {},
            child: Container(
              // height: MediaQuery.of(context).size.height * 0.3,
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    compassEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    markers: _markers,
                    mapType: MapType.satellite,
                    initialCameraPosition: cameraPosition,
                    polylines: {polylineRoute},
                    onMapCreated: (controller) async {
                      await _generateMarkers();
                      // Future.delayed(const Duration(microseconds: 100));
                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(bounds, 40));
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Icon(
                      MdiIcons.arrowExpandAll,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
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
                    StreamBuilder(
                      stream: _getImagesFromExcursion(),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return const Loader();
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
                                  "No se han compartido imágenes aún",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ));
                      },
                    ),
                  ],
                ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de la excursión', style: GoogleFonts.inter()),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              //TODO: continue to whatever
            },
          ),
        ],
      ),
      body: !_isLoading ? _buildBody() : Center(child: const Loader()),
    );
  }
}

class StatisticView extends StatelessWidget {
  final StatisticRecap statistics;
  const StatisticView({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumen",
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
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
                "Imágenes subidas",
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