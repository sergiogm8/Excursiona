import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/pages/create_excursion_page.dart';
import 'package:excursiona/pages/excursion_page.dart';
import 'package:excursiona/pages/landing_page.dart';
import 'package:excursiona/pages/map_page.dart';
import 'package:excursiona/pages/activity_page.dart';
import 'package:excursiona/pages/profile_page.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  Stream? chats;
  int currentIndex = 0;

  List<Widget> pages = [
    const LandingPage(),
    const ActivityPage(),
    const CreateExcursionPage(),
    const MapPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    _checkActiveExcursion();
    super.initState();
  }

  _checkActiveExcursion() {
    ExcursionController excursionController = ExcursionController();
    excursionController.getActiveExcursion().then((value) {
      if (value != null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Excursión activa"),
            content: const Text(
                "Tienes una excursión activa, ¿quieres continuarla?"),
            actions: [
              TextButton(
                  onPressed: () async {
                    await excursionController.leaveExcursion(
                        excursionId: value.id);
                    Navigator.pop(context);
                  },
                  child: Text("No",
                      style: GoogleFonts.inter(color: Colors.black))),
              TextButton(
                  onPressed: () {
                    nextScreen(
                        context,
                        ExcursionPage(
                          excursionId: value.id,
                          excursion: value,
                        ),
                        PageTransitionType.fade);
                  },
                  child: Text("Sí",
                      style: GoogleFonts.inter(color: Colors.black))),
            ],
          ),
        );
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      return;
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  _createExcursion() {
    nextScreen(
        context, const CreateExcursionPage(), PageTransitionType.bottomToTop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: Constants.indigoDye,
          onTap: _onItemTapped,
          unselectedItemColor: Colors.grey[500],
          // showUnselectedLabels: false,
          // showSelectedLabels: false,
          unselectedFontSize: 12,
          selectedFontSize: 12,
          iconSize: 24,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_rounded,
                ),
                label: "Inicio"),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.list_rounded,
                ),
                label: "Actividad"),
            BottomNavigationBarItem(
                icon: FloatingActionButton(
                  heroTag: "createExcursion",
                  elevation: 1,
                  onPressed: _createExcursion,
                  foregroundColor: Colors.white,
                  backgroundColor: Constants.indigoDye,
                  child: Icon(
                    Icons.landscape_rounded,
                    size: 40,
                  ),
                ),
                label: ""),
            const BottomNavigationBarItem(
              icon: Icon(
                MdiIcons.map,
              ),
              label: "Mapa",
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: "Mi perfil",
            ),
          ],
        ),
        body: pages.elementAt(currentIndex));
  }
}
