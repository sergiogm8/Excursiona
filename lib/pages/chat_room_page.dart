import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/message_type.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final ExcursionController excursionController;
  final Set<UserModel> users;
  const ChatRoomPage(
      {super.key, required this.excursionController, required this.users});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _messageController = ScrollController();
  ExcursionController get _excursionController => widget.excursionController;

  Stream<List<Message>> _getMessages() {
    return _excursionController.getMessages();
  }

  _sendMessage(String text) {
    _excursionController.sendTextMessage(text);
    print("Sending message: $text");
  }

  _drawChatList() {
    return StreamBuilder(
      stream: _getMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _messageController
              .jumpTo(_messageController.position.maxScrollExtent);
        });
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          shrinkWrap: true,
          controller: _messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Message message = snapshot.data![index];
            return isCurrentUser(message.senderID)
                ? MyChatBubble(message)
                : OtherChatBubble(message);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sala de chat",
          style: GoogleFonts.inter(),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Constants.darkWhite,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Expanded(child: _drawChatList()),
            BottomChatComponent(
              sendMessage: _sendMessage,
            )
          ],
        ),
      ),
    );
  }
}

class BottomChatComponent extends StatefulWidget {
  final Function sendMessage;
  const BottomChatComponent({super.key, required this.sendMessage});

  @override
  State<BottomChatComponent> createState() => _BottomChatComponentState();
}

class _BottomChatComponentState extends State<BottomChatComponent> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      height: 70,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              onChanged: (value) {
                setState(() {});
              },
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Escribe algo aquí",
                suffixIcon: _messageController.text.isEmpty
                    ? IconButton(
                        splashRadius: 20.0,
                        onPressed: () {},
                        icon: const Icon(Icons.mic),
                        color: Constants.indigoDye)
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Constants.darkGrey),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Constants.steelBlue, width: 2),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          IconButton(
            splashRadius: 20.0,
            onPressed: () {
              if (_messageController.text.trim().isEmpty) return;
              widget.sendMessage(_messageController.text.trim());
              setState(() {
                _messageController.clear();
              });
            },
            icon: const Icon(Icons.send),
            color: Constants.lapisLazuli,
          )
        ],
      ),
    );
  }
}

class MyChatBubble extends StatelessWidget {
  const MyChatBubble(this.message, {super.key});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Card(
          elevation: 5,
          color: Constants.lapisLazuli,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    message.type == MessageType.text
                        ? Text(
                            message.text,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Text("") // TODO: ADD AUDIO MESSAGE,
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      DateFormat("HH:mm").format(message.timeSent),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherChatBubble extends StatelessWidget {
  const OtherChatBubble(this.message, {super.key});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.senderPic.isNotEmpty
                ? CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(message.senderPic),
                    radius: 15,
                  )
                : AccountAvatar(radius: 15, name: message.senderName),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Card(
                  elevation: 5,
                  color: Constants.aliceBlue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 10,
                          bottom: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getNameAbbreviation(message.senderName),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Constants.indigoDye,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            message.type == MessageType.text
                                ? Text(
                                    message.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : Text("") // TODO: ADD AUDIO MESSAGE,
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                              DateFormat("HH:mm").format(message.timeSent),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Constants.lapisLazuli,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
