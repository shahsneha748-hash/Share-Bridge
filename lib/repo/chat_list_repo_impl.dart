import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_model.dart';
import 'chat_list_repo.dart';
import 'package:rxdart/rxdart.dart';

class ChatListRepoImpl implements ChatListRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ChatRoom>> listenToChatRooms(String userId) {
    final asReceiver = _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((s) => s.docs
        .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
        .toList());

    final asDonor = _firestore
        .collection('chats')
        .where('donorId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((s) => s.docs
        .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
        .toList());

    return Rx.combineLatest2<List<ChatRoom>, List<ChatRoom>, List<ChatRoom>>(
      asReceiver,
      asDonor,
          (a, b) {
        final merged = {...a, ...b}.toList();
        merged.sort((x, y) =>
            y.lastMessageTime.compareTo(x.lastMessageTime));
        return merged;
      },
    );
  }
}