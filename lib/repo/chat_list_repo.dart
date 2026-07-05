import '../model/chat_model.dart';

abstract class ChatListRepo {
  /// Returns a live stream of ChatRooms where the given userId
  /// is either the donor or the receiver.
  Stream<List<ChatRoom>> listenToChatRooms(String userId);
}