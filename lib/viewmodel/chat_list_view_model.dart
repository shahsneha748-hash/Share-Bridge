import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chat_model.dart';
import '../repo/chat_list_repo.dart';
import '../repo/chat_list_repo_impl.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatListRepo _repo = ChatListRepoImpl();
  StreamSubscription? _subscription;

  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> get chatRooms => _chatRooms;

  // Unread counts — keyed by chatId
  // TODO: replace with real unread count field from Firestore
  final Map<String, int> unreadCounts = {};

  String searchQuery = '';
  String selectedFilter = 'All'; // 'All' or 'Unread'

  bool isLoading = false;

  String get currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  int get totalUnreadChats =>
      _chatRooms.where((r) => (unreadCounts[r.chatId] ?? 0) > 0).length;

  List<ChatRoom> get filteredChats {
    return _chatRooms.where((room) {
      final matchesSearch = room.otherUserName
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final isUnread = (unreadCounts[room.chatId] ?? 0) > 0;
      final matchesFilter = selectedFilter == 'All' || isUnread;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  ChatListViewModel() {
    _listenToChatRooms();
  }

  void _listenToChatRooms() {
    if (currentUserId.isEmpty) return;
    isLoading = true;
    notifyListeners();

    _subscription =
        _repo.listenToChatRooms(currentUserId).listen((rooms) {
          _chatRooms = rooms;
          // Seed unread counts for new rooms that don't have one yet
          for (final room in rooms) {
            unreadCounts.putIfAbsent(room.chatId, () => 0);
          }
          isLoading = false;
          notifyListeners();
        }, onError: (e) {
          debugPrint('❌ CHAT LIST ERROR: $e');
          isLoading = false;
          notifyListeners();
        });
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void markAsRead(String chatId) {
    unreadCounts[chatId] = 0;
    notifyListeners();
  }

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}