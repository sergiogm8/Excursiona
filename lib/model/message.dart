import 'package:excursiona/enums/message_enums.dart';

class Message {
  final String senderID;
  final String recieverID;
  final String text;
  final DateTime timeSent;
  final MessageEnum type;
  final String messageID;
  final bool isRead;

  Message(
      {required this.senderID,
      required this.recieverID,
      required this.text,
      required this.timeSent,
      required this.type,
      required this.messageID,
      required this.isRead});

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'recieverID': recieverID,
      'text': text,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'type': type.type,
      'messageID': messageID,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      recieverID: map['recieverID'] ?? '',
      text: map['text'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      type: (map['type'] as String).toEnum(),
      messageID: map['messageID'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }
}
