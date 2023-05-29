import 'package:excursiona/enums/message_type.dart';

class Message {
  final String senderID;
  final String senderName;
  final String senderPic;
  final String text;
  final DateTime timeSent;
  final MessageType type;

  Message({
    required this.senderID,
    required this.senderName,
    required this.senderPic,
    required this.text,
    required this.timeSent,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderName': senderName,
      'senderPic': senderPic,
      'text': text,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'type': type.type,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderName: map['senderName'] ?? '',
      senderPic: map['senderPic'] ?? '',
      text: map['text'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      type: (map['type'] as String).toEnum(),
    );
  }
}
