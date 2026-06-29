abstract class ChatRepo {
  Stream<List<Map<String, dynamic>>> listenToMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> message);
}