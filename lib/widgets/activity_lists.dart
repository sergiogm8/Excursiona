import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/excursion_recap.dart';
import 'package:excursiona/pages/statistics_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';

class MyActivity extends StatefulWidget {
  const MyActivity({super.key});

  @override
  State<MyActivity> createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  bool _isLoading = true;
  bool _hasMore = true;
  List<ExcursionRecap> _items = [];

  ScrollController _scrollController = ScrollController();
  UserController _userController = UserController();

  @override
  void initState() {
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _fetchData();
      }
    });
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _fetchData() async {
    try {
      var newExcursions = await _userController.getUserExcursions();
      setState(() {
        if (newExcursions.isNotEmpty) {
          _hasMore = false;
        }
        _items.addAll(newExcursions);
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: Text("Cargando..."))
        : Container(
            decoration: const BoxDecoration(
              color: Constants.darkWhite,
            ),
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: _items.length + 1,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  if (_items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Center(child: Text("No hay excursiones que mostrar")),
                    );
                  }
                  if (index < _items.length) {
                    final item = _items[index];
                    return ActivityItem(item: item);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                          child: _hasMore
                              ? const Loader()
                              : const Text("No hay más datos que mostrar")),
                    );
                  }
                }),
          );
  }
}

class ActivityItem extends StatelessWidget {
  final ExcursionRecap item;
  const ActivityItem({super.key, required this.item});
  final iconsColor = Constants.lapisLazuli;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Constants.indigoDye),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: 'Dificultad: ',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: item.difficulty,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  item.description,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timelapse, color: iconsColor),
                        const SizedBox(width: 5.0),
                        Text(
                          '${item.duration.inHours.toString()}h ${(item.duration.inMinutes % 60).toString()}min',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(MdiIcons.mapMarkerDistance, color: iconsColor),
                        const SizedBox(width: 5.0),
                        Text(
                          "${item.distance.toStringAsFixed(2)} km",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.group, color: iconsColor),
                        const SizedBox(width: 5.0),
                        Text(
                          item.nParticipants.toString(),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(MdiIcons.runFast, color: iconsColor),
                        const SizedBox(width: 5.0),
                        Text(
                          '${item.avgSpeed.toStringAsFixed(1)}km/h',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CachedNetworkImage(
              placeholder: (context, url) => const Loader(),
              imageUrl: item.mapSnapshotUrl!,
              height: 150,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          // const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(item.date),
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Constants.indigoDye)),
                TextButton(
                    onPressed: () async {
                      try {
                        await ExcursionController()
                            .getExcursionById(item.id)
                            .then((value) {
                          nextScreen(
                            context,
                            StatisticsPage(excursion: value, isNew: false),
                            PageTransitionType.rightToLeft,
                          );
                        });
                      } catch (e) {
                        showSnackBar(context, Colors.red, e.toString());
                      }
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_new,
                          color: Constants.indigoDye,
                          size: 20,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          "Ver detalles",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Constants.indigoDye),
                        )
                      ],
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
