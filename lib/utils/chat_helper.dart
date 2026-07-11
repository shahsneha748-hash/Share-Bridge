import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHelper {
  static String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<String> openChat({
    required String otherUserId,
    required String otherUserName,
    String donationId = '',
    String donationTitle = '',
  }) async {
    final firestore = FirebaseFirestore.instance;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final myDoc = await firestore.collection('users').doc(currentUserId).get();
    final myName = myDoc.data()?['fullName'] ?? 'Unknown';
    final myPicture = myDoc.data()?['profilePicture'] ?? '';

    final otherDoc = await firestore.collection('users').doc(otherUserId).get();
    final otherPicture = otherDoc.data()?['profilePicture'] ?? '';

    final chatId = getChatId(currentUserId, otherUserId);

    await firestore.collection('chats').doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: myName,
        otherUserId: otherUserName,
      },
      'participantProfilePictures': {
        currentUserId: myPicture,
        otherUserId: otherPicture,
      },
      'donationId': donationId,
      'donationTitle': donationTitle,
    }, SetOptions(merge: true));

    return chatId;
  }
}