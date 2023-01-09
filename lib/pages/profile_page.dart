import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  String email;
  String name;
  ProfilePage({super.key, required this.name, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Perfil",
        ),
      ),
      body: Container(
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
              Text(widget.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text(widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20)),
            ],
          )),
      drawer: Drawer(
        child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              const Icon(Icons.account_circle, size: 100),
              Text(widget.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              Text(widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 15),
              const Divider(),
              ListTile(
                  title: const Text("Mi perfil",
                      style: TextStyle(color: Colors.black)),
                  leading: const Icon(Icons.person),
                  selected: true,
                  selectedColor: Theme.of(context).primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                  }),
              ListTile(
                title: const Text("Mis chats",
                    style: TextStyle(color: Colors.black)),
                selectedColor: Theme.of(context).primaryColor,
                leading: const Icon(Icons.chat_rounded),
                onTap: () {
                  Navigator.pop(context);
                  nextScreen(context, const HomePage());
                },
              ),
              ListTile(
                title: const Text("Cerrar sesión",
                    style: TextStyle(color: Colors.black)),
                leading: const Icon(Icons.logout),
                selectedColor: Theme.of(context).primaryColor,
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text("Cerrar sesión"),
                            content: const Text(
                                "¿Seguro que quieres cerrar la sesión?"),
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
                                          builder: (context) =>
                                              const LoginScreen()),
                                      (route) => false);
                                },
                                icon: const Icon(Icons.check),
                              ),
                            ]);
                      });
                },
              ),
            ]),
      ),
    );
  }
}
