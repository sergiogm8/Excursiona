import 'package:chat_app/model/chat_contact.dart';
import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

class ChatList extends StatefulWidget {
  final String receiverUserId;

  const ChatList({super.key, required this.receiverUserId});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: DBService().getUserMessages(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });
        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final message = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(message.timeSent);
            return Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: message.recieverID ==
                          AuthService().firebaseAuth.currentUser!.uid
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.recieverID ==
                                AuthService().firebaseAuth.currentUser!.uid
                            ? const Color.fromARGB(255, 255, 98, 98)
                            : const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: message.recieverID ==
                                      AuthService()
                                          .firebaseAuth
                                          .currentUser!
                                          .uid
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(timeSent,
                              style: TextStyle(
                                color: message.recieverID ==
                                        AuthService()
                                            .firebaseAuth
                                            .currentUser!
                                            .uid
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 12,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class BottomChatField extends StatefulWidget {
  final String receiverUserId;
  const BottomChatField({super.key, required this.receiverUserId});

  @override
  State<BottomChatField> createState() => _BottomChatField();
}

class _BottomChatField extends State<BottomChatField> {
  final TextEditingController messageController = TextEditingController();
  bool enableSend = false;

  void sendTextMessage() async {
    if (enableSend) {
      DBService().sendTextMessage(
          context: context,
          text: messageController.text.trimLeft(),
          recieverUserID: widget.receiverUserId);
      setState(() {
        messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                onChanged: ((value) {
                  if (value.trimLeft().isNotEmpty) {
                    setState(() {
                      enableSend = true;
                    });
                  } else {
                    setState(() {
                      enableSend = false;
                    });
                  }
                }),
                decoration: textInputDecoration.copyWith(
                    hintText: 'Type a message',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10)),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 25,
                child: GestureDetector(
                    onTap: sendTextMessage,
                    child: const Icon(Icons.send, color: Colors.white)))
          ],
        ));
  }
}

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            CircularProgressIndicator(color: Theme.of(context).primaryColor));
  }
}

class ContactTile extends StatelessWidget {
  final UserModel contactData;
  const ContactTile({super.key, required this.contactData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          //a leading circle avatar of large size
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(contactData.profilePic),
          ),
          title: Text(contactData.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // onTap: () {
          //   nextScreen(
          //       context,
          //       ChatPage(
          //         contactName: chatContactData.name,
          //         contactID: chatContactData.contactID,
          //         contactPicture: chatContactData.profilePic,
          //       ));
          // },
        ),
        const Divider(
          height: 5,
          thickness: 1,
        ),
      ],
    );
  }
}

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
