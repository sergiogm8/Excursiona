import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:excursiona/widgets/widgets.dart';
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
              stream: UserService().getUserDataByID(widget.contactID),
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
        body: Column(
          children: [
            Expanded(child: ChatList(receiverUserId: widget.contactID)),
            BottomChatField(receiverUserId: widget.contactID)
          ],
        ));
  }
}
