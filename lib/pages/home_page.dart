import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/model/chat_contact.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/contacts_page.dart';
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
  ChatService chatService = ChatService();
  String name = "";
  String email = "";
  Stream? chats;

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
    // await DBService(uid: FirebaseAuth.instance.currentUser!.uid)
    //     .getUserChats()
    //     .then((snapshots) {
    //   setState(() {
    //     chats = snapshots;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Mis chats",
          ),
        ),
        drawer: Drawer(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              children: <Widget>[
                const Icon(Icons.account_circle, size: 100),
                Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
                Text(email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 15),
                const Divider(),
                ListTile(
                    title: const Text("Mi perfil",
                        style: TextStyle(color: Colors.black)),
                    leading: const Icon(Icons.person),
                    selectedColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      nextScreen(
                          context,
                          ProfilePage(
                            name: name,
                            email: email,
                          ));
                    }),
                ListTile(
                  title: const Text("Mis chats",
                      style: TextStyle(color: Colors.black)),
                  selectedColor: Theme.of(context).primaryColor,
                  selected: true,
                  leading: const Icon(Icons.chat_rounded),
                  onTap: () {
                    Navigator.pop(context);
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
        body: chatList(),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              nextScreen(context, const ContactsPage());
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.chat)));
  }

  chatList() {
    var chatContacts = List<ChatContact>.empty(growable: true);
    chatContacts.add(ChatContact(
        name: "Juan",
        lastMessage: "Hola",
        timeSent: DateTime.now(),
        profilePic:
            "https://xsgames.co/randomusers/assets/avatars/pixel/25.jpg",
        contactID: "1234"));
    chatContacts.add(ChatContact(
        name: "Pedro",
        lastMessage: "Hola que tal hermano como te trata la vida",
        timeSent: DateTime.now(),
        profilePic:
            "https://xsgames.co/randomusers/assets/avatars/pixel/26.jpg",
        contactID: "4321"));
    // return StreamBuilder<List<ChatContact>>(
    //   stream: chatService.getChatsContacts(),
    //   builder: (context, AsyncSnapshot snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     } else {
    //       return ListView.builder(
    //         shrinkWrap: true,
    //         itemCount: snapshot.data!.length,
    //         itemBuilder: (context, index) {
    //           var chatContactData = snapshot.data![index];
    //           return ChatTile(chatContactData: chatContactData);
    //         },
    //       );
    //     }
    //   },
    // );
    return ListView.builder(
      shrinkWrap: true,
      itemCount: chatContacts.length,
      itemBuilder: (context, index) {
        var chatContactData = chatContacts[index];
        return ChatTile(chatContactData: chatContactData);
      },
    );
  }
}
