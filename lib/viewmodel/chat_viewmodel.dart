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

  final List<Message> messages = [
    Message(
      id: 0,
      text: "Hi! I saw you requested my Grocery Essentials Bundle 😊",
      isSender: false,
      timestamp: "9:12 AM",
    ),
    Message(
      id: 1,
      text: "Are you still interested in picking it up?",
      isSender: false,
      timestamp: "9:12 AM",
    ),
    Message(
      id: 2,
      text: "Yes! I'm very interested. Thank you so much for donating 🙏",
      isSender: true,
      timestamp: "9:14 AM",
    ),
    Message(
      id: 3,
      text: "When and where can I come to collect it?",
      isSender: true,
      timestamp: "9:14 AM",
    ),
    Message(
      id: 4,
      text: "You can pick it up today before 6pm at Imadol 5, near ABC Tol gate.",
      isSender: false,
      timestamp: "9:16 AM",
    ),
    Message(
      id: 5,
      text: "Perfect! I'll be there around 4pm. See you then! 😊",
      isSender: true,
      timestamp: "9:18 AM",
    ),
  ];

  String currentTime() {
    final now = DateTime.now();
    final h = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $amPm';
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(Message(
      id: ++_idCounter,
      text: text.trim(),
      isSender: true,
      timestamp: currentTime(),
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
          id: ++_idCounter,
          text: _botReplies[Random().nextInt(_botReplies.length)],
          isSender: false,
          timestamp: currentTime(),
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