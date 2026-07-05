import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_model.dart';
import 'chat_list_repo.dart';

class ChatListRepoImpl implements ChatListRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ChatRoom>> listenToChatRooms(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), doc.id, userId))
          .toList();
      // Sort newest first (in code, avoids Firestore composite index)
      rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return rooms;
    });
  }
}