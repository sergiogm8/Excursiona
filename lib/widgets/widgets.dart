import 'package:excursiona/model/chat_contact.dart';
import 'package:excursiona/model/contact.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/chat_page.dart';
import 'package:excursiona/pages/profile_page.dart';

import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

final textInputDecoration = InputDecoration(
  hintStyle: GoogleFonts.inter(
      color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
  contentPadding: const EdgeInsets.symmetric(vertical: 15),
  enabledBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.5),
  ),
  focusedBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: Constants.lapisLazuli, width: 2.0),
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
      stream: UserService().getUserMessages(widget.receiverUserId),
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
            return Align(
                alignment: message.recieverID ==
                        AuthService().firebaseAuth.currentUser!.uid
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                      minWidth: MediaQuery.of(context).size.width * 0.3,
                    ),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      color: message.recieverID ==
                              AuthService().firebaseAuth.currentUser!.uid
                          ? Constants.lightChatColor
                          : Constants.indigoDye,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 50,
                              top: 5,
                              bottom: 15,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: message.recieverID ==
                                            AuthService()
                                                .firebaseAuth
                                                .currentUser!
                                                .uid
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: Row(
                              children: [
                                Text(
                                  timeSent,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: message.recieverID ==
                                            AuthService()
                                                .firebaseAuth
                                                .currentUser!
                                                .uid
                                        ? Constants.darkGrey
                                        : Constants.lightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )));
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
      UserService().sendTextMessage(
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
                maxLines: null,
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  filled: true,
                ),
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
    return const Center(
        child: CircularProgressIndicator(color: Constants.lapisLazuli));
  }
}

class ContactTile extends StatelessWidget {
  const ContactTile({super.key, required this.contactData});
  final Contact contactData;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            //a leading circle avatar of large size
            leading: contactData.profilePic.isEmpty
                ? const Icon(Icons.account_circle, size: 60)
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(contactData.profilePic)),
            title: Text(contactData.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              nextScreenReplace(
                  context,
                  ChatPage(
                      contactID: contactData.contactID,
                      contactName: contactData.name,
                      contactPicture: contactData.profilePic),
                  PageTransitionType.rightToLeft);
            },
          ),
        ),
        const Divider(
          height: 5,
          thickness: 1,
        )
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
          leading: chatContactData.profilePic.isEmpty
              ? const Icon(Icons.account_circle, size: 60)
              : CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(chatContactData.profilePic)),
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
                ),
                PageTransitionType.rightToLeft);
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
