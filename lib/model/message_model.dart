enum MessageStatus { sent, delivered, read }

class Message {
  final int id;
  final String text;
  final bool isSender;
  final String timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isSender,
    required this.timestamp,
    this.status = MessageStatus.read,
  });
}