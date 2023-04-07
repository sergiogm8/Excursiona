import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/pages/auth_page.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
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
  String profilePic = "";
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
    await HelperFunctions.getUserProfilePic().then((value) {
      setState(() {
        profilePic = value!;
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
            CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                child: profilePic != ""
                    ? ClipOval(
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child:
                                Image.network(profilePic, fit: BoxFit.cover)))
                    : AccountAvatar(radius: 50, name: name)),
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
                    _signout();
                  },
                  icon: const Icon(Icons.check),
                ),
              ]);
        });
  }

  void _signout() async {
    var couldExit = await AuthController().signOut();
    if (couldExit != true) {
      Navigator.pop(context);
      showSnackBar(context, Colors.red, couldExit);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false);
  }
}
