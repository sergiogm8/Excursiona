import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/model/chat_contact.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/contacts_page.dart';
import 'package:chat_app/pages/map_page.dart';
import 'package:chat_app/pages/my_chats_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/login_screen.dart';

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
    const ProfilePage(),
    const MapPage()
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
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded), label: "Mis chats"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Mi perfil"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          ],
        ),
        body: pages.elementAt(currentIndex));
  }
}
