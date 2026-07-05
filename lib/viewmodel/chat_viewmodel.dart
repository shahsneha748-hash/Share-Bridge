import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/message_model.dart';
import '../repo/chat_repo.dart';
import '../repo/chat_repo_impl.dart';

class ChatViewModel extends ChangeNotifier {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String donationTitle;

  final ChatRepo _repo = ChatRepoImpl();

  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final List<Message> messages = [];

  StreamSubscription? _messageSubscription;

  bool isTyping = false;
  String? _cachedUserName;
  String? otherUserPhone;

  final List<String> quickReplies = [
    "I'm on my way",
    "Thank you !",
    "Can we reschedule?",
    "Got it",
  ];

  ChatViewModel({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.donationTitle,
  }) {
    listenToMessages();
    _loadOtherUserPhone();
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

  /// Fetch the other user's phone number for the call button
  Future<void> _loadOtherUserPhone() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      otherUserPhone = doc.data()?['phone'];
      notifyListeners();
    } catch (_) {
      otherUserPhone = null;
    }
  }

  Future<String> _getCurrentUserName() async {
    if (_cachedUserName != null) return _cachedUserName!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      _cachedUserName = doc.data()?['fullName'] ??
          FirebaseAuth.instance.currentUser?.displayName ??
          'Unknown';
    } catch (_) {
      _cachedUserName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown';
    }
    return _cachedUserName!;
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final trimmed = text.trim();
    inputController.clear();

    final myName = await _getCurrentUserName();

    // 1️⃣ Update the parent chat document (participant style)
    await _repo.updateChatRoom(chatId, {
      'participants': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: myName,
        otherUserId: otherUserName,
      },
      'donationTitle': donationTitle,
      'lastMessage': trimmed,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // 2️⃣ Save the actual message
    await _repo.sendMessage(chatId, {
      'text': trimmed,
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