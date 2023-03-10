import 'package:excursiona/pages/map_page.dart';
import 'package:excursiona/pages/my_chats_page.dart';
import 'package:excursiona/pages/post_screen.dart';
import 'package:excursiona/pages/profile_page.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
    const MyChatsPage(),
    const PostScreen(),
    const MapPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      ExcursionService().createExcursion();
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          backgroundColor: Colors.grey[900],
          unselectedItemColor: Colors.grey[500],
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded), label: "Mis chats"),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Añadir"),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Mapa",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Mi perfil"),
          ],
        ),
        body: pages.elementAt(currentIndex));
  }
}
