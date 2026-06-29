import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/message_model.dart';
import '../repo/chat_repo.dart';
import '../repo/chat_repo_impl.dart';

class ChatViewModel extends ChangeNotifier {
  final String chatId;
  final String donorId;
  final String donorName;

  final ChatRepo _repo = ChatRepoImpl();

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final List<Message> messages = [];

  StreamSubscription? _messageSubscription;

  bool isTyping = false;

  final List<String> quickReplies = [
    "I'm on my way",
    "Thank you !",
    "Can we reschedule?",
    "Got it",
  ];

  ChatViewModel({
    required this.chatId,
    required this.donorId,
    required this.donorName,
  }) {
    listenToMessages();
  }

  void listenToMessages() {
    _messageSubscription =
        _repo.listenToMessages(chatId).listen((messageMaps) {
          messages.clear();
          for (var map in messageMaps) {
            messages.add(Message.fromMap(map, map['id'], currentUserId));
          }
          notifyListeners();
          scrollToBottom();
        });
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    inputController.clear();

    await _repo.sendMessage(chatId, {
      'text': text.trim(),
      'senderId': currentUserId,
      'timestamp': DateTime.now(),
      'status': 'sent',
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}