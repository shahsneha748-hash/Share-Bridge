import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatId;
  final String donationId;
  final String donationTitle;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final List<String> mutedBy;

  // Computed for current user
  final String otherUserId;
  final String otherUserName;
  final String otherUserInitial;

  ChatRoom({
    required this.chatId,
    required this.donationId,
    required this.donationTitle,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserInitial,
    required this.mutedBy,
  });

  factory ChatRoom.fromMap(
      Map<String, dynamic> map, String id, String currentUserId) {
    final participants = List<String>.from(map['participants'] ?? []);
    final participantNames =
    Map<String, String>.from(map['participantNames'] ?? {});

    // The other user = whoever in participants is NOT me
    final otherId = participants.firstWhere(
          (uid) => uid != currentUserId,
      orElse: () => '',
    );
    final otherName = participantNames[otherId] ?? 'Unknown';

    return ChatRoom(
      chatId: id,
      donationId: map['donationId'] ?? '',
      donationTitle: map['donationTitle'] ?? '',
      participants: participants,
      participantNames: participantNames,
      mutedBy: List<String>.from(map['mutedBy'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
      (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: map['isOnline'] ?? false,
      otherUserId: otherId,
      otherUserName: otherName,
      otherUserInitial:
      otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
    );
  }
  bool isMutedBy(String userId) => mutedBy.contains(userId);
}