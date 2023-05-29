enum MessageType {
  text('text'),
  audio('audio');

  const MessageType(this.type);
  final String type;
}

extension ConvertMessage on String {
  MessageType toEnum() {
    switch (this) {
      case 'text':
        return MessageType.text;
      case 'audio':
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }
}
