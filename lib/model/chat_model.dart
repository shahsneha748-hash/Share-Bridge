import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatId;
  final String donationId;
  final String donationTitle;
  final String donorId;
  final String receiverId;
  final String otherUserName;
  final String otherUserInitial;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;

  ChatRoom({
    required this.chatId,
    required this.donationId,
    required this.donationTitle,
    required this.donorId,
    required this.receiverId,
    required this.otherUserName,
    required this.otherUserInitial,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
  });

  // Convert Firestore document to ChatRoom object
  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      chatId: id,
      donationId: map['donationId'] ?? '',
      donationTitle: map['donationTitle'] ?? '',
      donorId: map['donorId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      otherUserName: map['otherUserName'] ?? '',
      otherUserInitial: map['otherUserInitial'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      isOnline: map['isOnline'] ?? false,
    );
  }

  // Convert ChatRoom object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donationTitle': donationTitle,
      'donorId': donorId,
      'receiverId': receiverId,
      'otherUserName': otherUserName,
      'otherUserInitial': otherUserInitial,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isOnline': isOnline,
    };
  }
}