import 'package:chat_app/model/chat_contact.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.grey),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255, 255, 98, 98), width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255, 255, 98, 98), width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255, 255, 98, 98), width: 2.0),
  ),
);

class ChatTile extends StatelessWidget {
  final ChatContact chatContactData;
  const ChatTile({super.key, required this.chatContactData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          //a leading circle avatar of large size
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(chatContactData.profilePic),
          ),
          title: Text(chatContactData.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(
            chatContactData.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(DateFormat('H:mm').format(chatContactData.timeSent),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            nextScreen(
                context,
                ChatPage(
                  contactName: chatContactData.name,
                  contactID: chatContactData.contactID,
                  contactPicture: chatContactData.profilePic,
                ));
          },
        ),
        const Divider(
          height: 5,
          thickness: 1,
        ),
      ],
    );
  }
}

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          // Some code to undo the change.
        },
      )));
}
