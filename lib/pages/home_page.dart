import 'package:chat_app/pages/map_page.dart';
import 'package:chat_app/pages/my_chats_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';

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
    const MapPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded), label: "Mis chats"),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Mapa",
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Mi perfil"),
          ],
        ),
        body: pages.elementAt(currentIndex));
  }
}
