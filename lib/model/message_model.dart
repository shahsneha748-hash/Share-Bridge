import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String text;
  final String senderId;
  final bool isSender;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isSender,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  // Converts DateTime to readable time string e.g. "9:14 AM"
  String get formattedTime {
    final h = timestamp.hour == 0
        ? 12
        : timestamp.hour > 12
        ? timestamp.hour - 12
        : timestamp.hour;
    final m = timestamp.minute.toString().padLeft(2, '0');
    final amPm = timestamp.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $amPm';
  }

  // Convert Firestore document to Message object
  factory Message.fromMap(Map<String, dynamic> map, String id,
      String currentUserId) {
    return Message(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      isSender: map['senderId'] == currentUserId,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  // Convert Message object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
      'status': status.name,
    };
  }
}