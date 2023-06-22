import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/pages/statistics_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
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
  static const int _docsLimit = 10;
  final ScrollController _scrollController = ScrollController();
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _fetchData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _fetchData() async {
    try {
      var newExcursions = await _userController.getUserExcursions(_docsLimit);
      setState(() {
        if (newExcursions.length < _docsLimit) {
          _hasMore = false;
        }
        _items.addAll(newExcursions);
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: Loader())
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

class CommunityActivity extends StatefulWidget {
  const CommunityActivity({super.key});

  @override
  State<CommunityActivity> createState() => _CommunityActivityState();
}

class _CommunityActivityState extends State<CommunityActivity> {
  bool _isLoading = true;
  bool _hasMore = true;
  List<ExcursionRecap> _items = [];

  static const int _docsLimit = 10;
  final ScrollController _scrollController = ScrollController();
  final ExcursionController _excursionController = ExcursionController();

  @override
  void initState() {
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _fetchData();
      }
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
      var newExcursions =
          await _excursionController.getTLExcursions(_docsLimit);
      setState(() {
        if (newExcursions.length < _docsLimit) {
          _hasMore = false;
        }
        _items.addAll(newExcursions);
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
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

class ActivityItem extends StatefulWidget {
  final ExcursionRecap item;
  const ActivityItem({super.key, required this.item});

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  final iconsColor = Constants.lapisLazuli;
  String _profilePic = "";

  @override
  void initState() {
    _getUserPic();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getUserPic() async {
    if (!isCurrentUser(widget.item.userId)) {
      UserController().getUserPic(widget.item.userId).then((value) {
        if (this.mounted) {
          setState(() {
            _profilePic = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await ExcursionController()
              .getExcursionById(widget.item.id)
              .then((value) {
            nextScreen(
              context,
              StatisticsPage(
                  excursion: value, userId: widget.item.userId, isNew: false),
              PageTransitionType.rightToLeft,
            );
          });
        } catch (e) {
          showSnackBar(context, Colors.red, e.toString());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Constants.border,
            boxShadow: Constants.boxShadow),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser(widget.item.userId))
                    Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _profilePic.isEmpty
                              ? AccountAvatar(
                                  radius: 20, name: widget.item.userName)
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      CachedNetworkImageProvider(_profilePic),
                                ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          widget.item.userName,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Constants.indigoDye),
                        ),
                      ],
                    ),
                  if (!isCurrentUser(widget.item.userId))
                    const SizedBox(height: 12.0),
                  Text(
                    widget.item.title,
                    overflow: TextOverflow.ellipsis,
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
                          text: widget.item.difficulty,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                            '${widget.item.duration.inHours.toString()}h ${(widget.item.duration.inMinutes % 60).toString()}min',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(MdiIcons.mapMarkerDistance, color: iconsColor),
                          const SizedBox(width: 5.0),
                          Text(
                            "${widget.item.distance.toStringAsFixed(2)} km",
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.group, color: iconsColor),
                          const SizedBox(width: 5.0),
                          Text(
                            widget.item.nParticipants.toString(),
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(MdiIcons.runFast, color: iconsColor),
                          const SizedBox(width: 5.0),
                          Text(
                            '${widget.item.avgSpeed.toStringAsFixed(1)}km/h',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w300),
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
                imageUrl: widget.item.mapSnapshotUrl!,
                height: 150,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Constants.border,
                      boxShadow: Constants.boxShadow,
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
                  Text(DateFormat('dd/MM/yyyy').format(widget.item.date),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          color: Constants.indigoDye)),
                  TextButton(
                      onPressed: () async {
                        try {
                          await ExcursionController()
                              .getExcursionById(widget.item.id)
                              .then((value) {
                            nextScreen(
                              context,
                              StatisticsPage(
                                  excursion: value,
                                  userId: widget.item.userId,
                                  isNew: false),
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
      ),
    );
  }
}
