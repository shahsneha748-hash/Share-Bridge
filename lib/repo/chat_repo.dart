abstract class ChatRepo {
  Stream<List<Map<String, dynamic>>> listenToMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> message);
  Future<void> updateChatRoom(String chatId, Map<String, dynamic> data);
  Future<void> toggleMute(String chatId, String userId, bool mute);
}