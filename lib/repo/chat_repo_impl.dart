import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Map<String, dynamic>>> listenToMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
  }

  @override
  Future<void> updateChatRoom(String chatId, Map<String, dynamic> data) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .set(data, SetOptions(merge: true));
  }
}