import '../model/chat_model.dart';

abstract class ChatListRepo {

  Stream<List<ChatRoom>> listenToChatRooms(String userId);
}