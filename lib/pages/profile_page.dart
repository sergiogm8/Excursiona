import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/pages/landing_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String email = "";
  String name = "";
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    await HelperFunctions.getUserEmail().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        name = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Perfil",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(email,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20)),
            ElevatedButton(
                onPressed: () => _logout(), child: const Text("Cerrar sesión"))
          ],
        ),
      ),
    );
  }

  void _logout() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Cerrar sesión"),
              content: const Text("¿Seguro que quieres cerrar la sesión?"),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel)),
                IconButton(
                  onPressed: () async {
                    await authService.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LandingPage()),
                        (route) => false);
                  },
                  icon: const Icon(Icons.check),
                ),
              ]);
        });
  }
}
