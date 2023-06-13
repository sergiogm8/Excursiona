import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/bottom_chat_component.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:excursiona/widgets/my_chat_bubble.dart';
import 'package:excursiona/widgets/other_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRoomPage extends StatefulWidget {
  final ExcursionController excursionController;
  const ChatRoomPage({super.key, required this.excursionController});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _messageController = ScrollController();
  ExcursionController get _excursionController => widget.excursionController;

  Stream<List<Message>> _getMessages() {
    return _excursionController.getMessages();
  }

  _sendTextMessage(String text) {
    _excursionController.sendTextMessage(text);
  }

  _sendAudioMessage(String path) async {
    await _excursionController.sendAudioMessage(path);
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
            const Divider(
              height: 1,
            ),
            BottomChatComponent(
              sendTextMessage: _sendTextMessage,
              sendAudioMessage: _sendAudioMessage,
            )
          ],
        ),
      ),
    );
  }
}
