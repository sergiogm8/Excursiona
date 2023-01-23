import 'package:chat_app/model/contact.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var contacts = <Contact>[];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserContacts();
    _isLoading = false;
  }

  getUserContacts() async {
    var user = await DBService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getCurrentUserData();
    var contactsId = user!.contactsID;

    for (var id in contactsId) {
      await DBService().getFutureUserDataByID(id).then((userData) {
        var contact = Contact(
            name: userData.name,
            profilePic: userData.profilePic,
            contactID: userData.uid);
        setState(() {
          contacts.add(contact);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Mis contactos"),
        ),
        body: _isLoading
            ? const Loader()
            : ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  return ContactTile(contactData: contacts[index]);
                },
              )
        // body: Text(DBService(uid: FirebaseAuth.instance.currentUser!.uid)
        //     .getContactsInfo()
        //     .toString()),
        // body: StreamBuilder(
        //   stream: contacts,
        //   builder: (context, AsyncSnapshot snapshot) {
        //     if (snapshot.hasData) {
        //       if (snapshot.data['contacts'] != null) {
        //         return ListView.builder(
        //           shrinkWrap: true,
        //           itemCount: snapshot.data['contacts'].length,
        //           itemBuilder: (context, index) {
        //             var contactId = snapshot.data['contacts'][index];
        //             var userData = getContactData(contactId);
        //             return ContactTile(contactData: userData);
        //             // return const Center(child: Text("hola"));
        //           },
        //         );
        //       } else {
        //         return const Center(child: Text("No tienes contactos"));
        //       }
        //     } else {
        //       return const Loader();
        //     }
        //   },
        // ),
        );
  }

  // getContactData(contactId) async {
  //   return DBService().getUserDataById2(contactId);
  // }
}
