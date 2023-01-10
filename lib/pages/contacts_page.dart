import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Mis contactos"),
        ),
        body: StreamBuilder<List<UserModel>>(
            stream: DBService().getContacts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                // return ListView.builder(
                //   shrinkWrap: true,
                //   itemCount: snapshot.data!.length,
                //   itemBuilder: (context, index) {
                //     var contactData = snapshot.data![index];
                //     return ContactTile(contactData: contactData);
                return const Center(child: Text("hola"));
              }
            }));
  }
}
