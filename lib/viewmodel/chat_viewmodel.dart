import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/message_model.dart';

class ChatViewModel extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isTyping = false;
  int _idCounter = 5;

  final List<String> quickReplies = [
    "I'm on my way",
    "Thank you !",
    "Can we reschedule?",
    "Got it",
  ];

  final List<String> _botReplies = [
    "Sure! See you then 😊",
    "Great! I'll have everything ready.",
    "Perfect, looking forward to it!",
    "Sounds good! 👍",
    "Okay, I'll be here waiting.",
    "No problem at all! See you soon.",
  ];

  // Replace with FirebaseAuth.instance.currentUser!.uid when Firebase ready
  final String currentUserId = 'user_me';

  final List<Message> messages = [
    Message(
      id: '0',
      text: "Hi! I saw you requested my Grocery Essentials Bundle 😊",
      senderId: 'user_ram',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Message(
      id: '1',
      text: "Are you still interested in picking it up?",
      senderId: 'user_ram',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
    ),
    Message(
      id: '2',
      text: "Yes! I'm very interested. Thank you so much for donating 🙏",
      senderId: 'user_me',
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
    ),
    Message(
      id: '3',
      text: "When and where can I come to collect it?",
      senderId: 'user_me',
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
    ),
    Message(
      id: '4',
      text: "You can pick it up today before 6pm at Imadol 5, near ABC Tol gate.",
      senderId: 'user_ram',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    Message(
      id: '5',
      text: "Perfect! I'll be there around 4pm. See you then! 😊",
      senderId: 'user_me',
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
      status: MessageStatus.read,
    ),
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(Message(
      id: (++_idCounter).toString(),
      text: text.trim(),
      senderId: currentUserId,
      isSender: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    ));
    inputController.clear();
    notifyListeners();
    scrollToBottom();
    simulateBotReply();
  }

  void simulateBotReply() {
    Timer(const Duration(milliseconds: 900), () {
      isTyping = true;
      notifyListeners();
      scrollToBottom();
      Timer(const Duration(milliseconds: 1400), () {
        isTyping = false;
        messages.add(Message(
          id: (++_idCounter).toString(),
          text: _botReplies[Random().nextInt(_botReplies.length)],
          senderId: 'user_ram',
          isSender: false,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
        scrollToBottom();
      });
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
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}