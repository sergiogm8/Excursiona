import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/profile_page.dart';
import 'package:excursiona/pages/statistics_page.dart';
import 'package:excursiona/pages/user_gallery_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/activity_lists.dart';
import 'package:excursiona/widgets/excursion_invitation_card.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weather/weather.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Position? _currentPosition;
  bool _hasLocation = false;
  bool _loadingUserData = true;
  bool _loadingWeatherData = false;
  bool _loadingRecentExcursions = true;
  StreamSubscription<ServiceStatus>? _locationStream;
  String _locationString = "  -  ";
  String _temperatureString = " - ";
  UserModel _user = UserModel();
  String _weatherDescription = "";
  final WeatherFactory _weatherFactory =
      WeatherFactory(Constants.openWeatherMapKey, language: Language.SPANISH);
  final int _docsLimit = 3;

  List<ExcursionRecap> _recentExcursions = [];

  String _weatherIcon = "";
  final String _weatherString = "El tiempo en  ";

  @override
  void dispose() {
    _locationStream?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _locationStream = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        _loadWeatherData();
      }
    });
    _loadUserData();
    _fetchRecentExcursions();
    _loadWeatherData();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _loadingWeather() {
    setState(() {
      _locationString = " Cargando... ";
    });
  }

  Stream<List<Excursion>> _getExcursionNotifications() {
    return UserController().getExcursionInvitations();
  }

  _loadWeatherData() {
    getCurrentPosition().then((value) {
      setState(() {
        _hasLocation = true;
        _loadingWeatherData = true;
      });
      _loadingWeather();
      _currentPosition = value;
      _weatherFactory
          .currentWeatherByLocation(
              _currentPosition!.latitude, _currentPosition!.longitude)
          .then((value) {
        setState(() {
          _loadingWeatherData = false;
          _locationString = value.areaName!;
          _temperatureString = value.temperature!.celsius!.toStringAsFixed(0);
          _weatherDescription = value.weatherDescription!;
          _weatherIcon = _getWeatherIcon(value.weatherIcon!);
        });
      });
    }).catchError((error) {
      showSnackBar(context, Colors.red, error.toString());
    });
  }

  _getWeatherIcon(String icon) {
    return "https://openweathermap.org/img/wn/$icon@4x.png";
  }

  void _loadUserData() async {
    var userInfo = await UserController().getUserBasicInfo();
    setState(() {
      _user = userInfo;
      _loadingUserData = false;
    });
  }

  _fetchRecentExcursions() async {
    try {
      var excursions = await UserController().getUserExcursions(_docsLimit);
      setState(() {
        _recentExcursions = excursions;
        _loadingRecentExcursions = false;
      });
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es');
    var date = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM', 'es').format(date);
    formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Positioned.fill(
          bottom: MediaQuery.of(context).size.height * 0.3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1],
                colors: [
                  Constants.indigoDye,
                  Color(0xFF287462),
                ],
              ),
            ),
            child: _loadingUserData
                ? const Center(
                    child: Loader(
                      color: Colors.white,
                    ),
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    "¡Hola, ${_user.name.split(" ")[0]}!",
                                    minFontSize: 22,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _user.profilePic.isEmpty
                                    ? AccountAvatar(
                                        minRadius: 35,
                                        maxRadius: 45,
                                        name: _user.name)
                                    : CircleAvatar(
                                        maxRadius: 45,
                                        minRadius: 35,
                                        // radius: box.maxWidth / 2,
                                        backgroundColor: Constants.darkWhite,
                                        child: CachedNetworkImage(
                                          imageUrl: _user.profilePic,
                                          placeholder: (context, url) =>
                                              Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Constants.darkWhite,
                                                  ),
                                                  child: const Loader()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          placeholderFadeInDuration:
                                              const Duration(milliseconds: 300),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            AutoSizeText(
                              _weatherString + _locationString,
                              minFontSize: 16,
                              maxLines: 1,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 28),
                            if (_loadingWeatherData)
                              const Center(
                                child: Loader(
                                  color: Colors.white,
                                ),
                              )
                            else if (_hasLocation)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: _weatherIcon.isEmpty
                                        ? const SizedBox()
                                        : CachedNetworkImage(
                                            imageUrl: _weatherIcon,
                                            placeholder: (context, url) =>
                                                const Loader(
                                              color: Colors.white,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              Icons.error,
                                              color: Colors.white,
                                              size: 42,
                                            ),
                                          ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        Text(
                                          "$_temperatureStringºC",
                                          style: GoogleFonts.inter(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _weatherDescription.isEmpty
                                              ? _weatherDescription
                                              : _weatherDescription[0]
                                                      .toUpperCase() +
                                                  _weatherDescription
                                                      .substring(1),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Center(
                                child: Text(
                                    "Activa la ubicación para ver el clima",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white)),
                              ),
                          ]),
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.38,
          right: 32,
          child: Text(
            formattedDate,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ),
        Positioned.fill(
          child: DraggableScrollableSheet(
            minChildSize: 0.4,
            maxChildSize: 0.8,
            initialChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Constants.darkWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Invitaciones",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        StreamBuilder(
                          stream: _getExcursionNotifications(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return const Loader();
                            }
                            return snapshot.data!.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          ExcursionInvitationCard(
                                            excursion: snapshot.data![index],
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          )
                                        ],
                                      );
                                    },
                                  )
                                : const Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "No hay invitaciones recientes",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                        // Spacer(),
                        // const SizedBox(height: 20)
                        const SizedBox(height: 20),
                        Text(
                          "Excursiones recientes",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        if (_loadingRecentExcursions)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Loader(),
                          )
                        else if (_recentExcursions.isEmpty)
                          const Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "No se han registrado excursiones aún",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 270,
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              shrinkWrap: false,
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentExcursions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 5),
                                  child: SmallActivityItem(
                                      _recentExcursions[index]),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            nextScreen(context, const UserGalleryPage(),
                                PageTransitionType.rightToLeft);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.indigoDye,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Tu galería de imágenes",
                              ),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

class SmallActivityItem extends StatelessWidget {
  final ExcursionRecap data;
  const SmallActivityItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await ExcursionController().getExcursionById(data.id).then((value) {
            nextScreen(
              context,
              StatisticsPage(
                  excursion: value, userId: data.userId, isNew: false),
              PageTransitionType.rightToLeft,
            );
          });
        } catch (e) {
          showSnackBar(context, Colors.red, e.toString());
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Constants.border,
            boxShadow: Constants.boxShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 110,
            child: CachedNetworkImage(
                fit: BoxFit.cover,
                // width: 100,
                imageUrl: data.mapSnapshotUrl!,
                placeholder: (_, url) => const Loader(),
                imageBuilder: (_, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: "Duración: ",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text:
                  "${data.duration.inHours.toString()}h ${(data.duration.inMinutes % 60).toString()}min",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400, color: Colors.grey[600]),
            ),
          ])),
          const SizedBox(height: 5),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: "Distancia recorrida: ",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: "${data.distance.toStringAsFixed(2)}km",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400, color: Colors.grey[600]),
            ),
          ])),
          const SizedBox(height: 5),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: "Participantes: ",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            TextSpan(
              text: data.nParticipants.toString(),
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400, color: Colors.grey[600]),
            ),
          ]))
        ]),
      ),
    );
  }
}
