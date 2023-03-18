import 'package:excursiona/model/chat_contact.dart';
import 'package:excursiona/pages/contacts_page.dart';
import 'package:excursiona/services/chat_service.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MyChatsPage extends StatefulWidget {
  const MyChatsPage({super.key});

  @override
  State<MyChatsPage> createState() => _MyChatsPageState();
}

class _MyChatsPageState extends State<MyChatsPage> {
  ChatService chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Mis chats",
        ),
      ),
      body: _buildChatsList(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            nextScreen(
                context, const ContactsPage(), PageTransitionType.rightToLeft);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.chat)),
    );
  }

  _buildChatsList() {
    return StreamBuilder<List<ChatContact>>(
      stream: chatService.getChatsContacts(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var chatContactData = snapshot.data![index];
              return ChatTile(chatContactData: chatContactData);
            },
          );
        }
      },
    );
  }
}
