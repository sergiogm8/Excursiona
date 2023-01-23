import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String contactID;

  final String contactName;

  final String contactPicture;
  const ChatPage(
      {super.key,
      required this.contactName,
      required this.contactID,
      required this.contactPicture});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: StreamBuilder<UserModel>(
              stream: DBService().getUserDataByID(widget.contactID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.contactPicture.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.contactPicture),
                          )
                        : const Icon(
                            Icons.account_circle,
                            size: 50,
                          ),
                    const SizedBox(width: 10),
                    Text(widget.contactName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                );
              }),
        ),
        // backgroundColor: const Color.fromARGB(245, 245, 245, 245),
        body: Column(
          children: [
            Expanded(child: ChatList(receiverUserId: widget.contactID)),
            BottomChatField(receiverUserId: widget.contactID)
          ],
        ));
  }
}
