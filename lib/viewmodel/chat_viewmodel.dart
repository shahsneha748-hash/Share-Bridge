import 'dart:async';
import 'package:flutter/material.dart';
import '../model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatViewModel extends ChangeNotifier {
  final String chatId;
  final String donorId;
  final String donorName;

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final List<Message> messages = [];

  StreamSubscription? _messageSubscription;

  ChatViewModel({
    required this.chatId,
    required this.donorId,
    required this.donorName,
  }) {
    listenToMessages();
  }

  bool isTyping = false;

  final List<String> quickReplies = [
    "I'm on my way",
    "Thank you !",
    "Can we reschedule?",
    "Got it",
  ];

  void listenToMessages() {
    _messageSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      messages.clear();
      for (var doc in snapshot.docs) {
        messages.add(Message.fromMap(doc.data(), doc.id, currentUserId));
      }
      notifyListeners();
      scrollToBottom();
    });
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    inputController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
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