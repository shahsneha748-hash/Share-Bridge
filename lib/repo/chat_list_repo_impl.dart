import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_model.dart';
import 'chat_list_repo.dart';

class ChatListRepoImpl implements ChatListRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ChatRoom>> listenToChatRooms(String userId) {
    // Fetch all chat rooms where current user is the receiver
    // TODO: if you also want rooms where the user is the donor,
    // merge two streams. For now this covers the receiver side.
    return _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
        .toList());
  }
}