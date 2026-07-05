import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHelper {
  /// Same 2 people always produce the same chatId
  static String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Call this when ANY user taps a "Chat" button.
  /// Works for user↔donor, user↔volunteer, donor↔volunteer.
  /// Returns the chatId to navigate with.
  static Future<String> openChat({
    required String otherUserId,
    required String otherUserName,
    String donationId = '',
    String donationTitle = '',
  }) async {
    final firestore = FirebaseFirestore.instance;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Get my own name from users collection
    final myDoc =
    await firestore.collection('users').doc(currentUserId).get();
    final myName = myDoc.data()?['fullName'] ?? 'Unknown';

    final chatId = getChatId(currentUserId, otherUserId);

    // Create chat doc if it doesn't exist (merge = won't overwrite)
    await firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: myName,
        otherUserId: otherUserName,
      },
      'donationId': donationId,
      'donationTitle': donationTitle,
    }, SetOptions(merge: true));

    return chatId;
  }
}