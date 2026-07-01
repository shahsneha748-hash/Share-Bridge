import 'package:flutter/material.dart';
import 'package:sharebridge/model/chat_model.dart';
import 'package:sharebridge/components/default_avatar.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/view/donation_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatRoom> chatRooms = [
    ChatRoom(
      chatId: 'c1',
      donationId: 'd1',
      donationTitle: 'Grocery Essentials Bundle',
      donorId: 'user_ram',
      receiverId: 'user_me',
      otherUserName: 'Sonu Singh',
      otherUserInitial: 'S',
      lastMessage: 'kina',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 40)),
      isOnline: true,
    ),
    ChatRoom(
      chatId: 'c2',
      donationId: 'd2',
      donationTitle: 'Cooked Meal',
      donorId: 'user_ram',
      receiverId: 'user_me',
      otherUserName: 'Shweta Bhandari',
      otherUserInitial: 'S',
      lastMessage: 'Shweta sent an attachment.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isOnline: false,
    ),
    ChatRoom(
      chatId: 'c3',
      donationId: 'd3',
      donationTitle: 'Winter Jacket',
      donorId: 'user_kishika',
      receiverId: 'user_me',
      otherUserName: 'Kishika Dangi',
      otherUserInitial: 'K',
      lastMessage: 'Kishika sent an attachment.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isOnline: true,
    ),
  ];

  // TODO: replace with real unread counts from Firestore
  final Map<String, int> _unreadCounts = {
    'c1': 1,
    'c2': 2,
    'c3': 0,
  };

  String _searchQuery = '';
  String _selectedFilter = 'All';

  int get _totalUnreadChats =>
      chatRooms.where((r) => (_unreadCounts[r.chatId] ?? 0) > 0).length;

  List<ChatRoom> get _filteredChats {
    return chatRooms.where((room) {
      final matchesSearch = room.otherUserName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final isUnread = (_unreadCounts[room.chatId] ?? 0) > 0;
      final matchesFilter = _selectedFilter == 'All' || isUnread;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget _filterChip(String label, {int? badge}) {
    final bool active = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF3A5C2E)
              : const Color(0xFFE7DFC8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF3A5C2E),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 5),
              Text(
                '$badge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF3A5C2E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── HEADER — same as all other screens ───────────────────
            const AppHeader(title: 'Chats'),

            const SizedBox(height: 16),

            // ── SEARCH BAR ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search, color: Colors.grey, size: 21),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── FILTER CHIPS — All / Unread ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip('All'),
                  _filterChip('Unread', badge: _totalUnreadChats),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── CHAT LIST ─────────────────────────────────────────────
            Expanded(
              child: _filteredChats.isEmpty
                  ? const Center(
                child: Text(
                  'No conversations found',
                  style:
                  TextStyle(color: Colors.grey, fontSize: 15),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredChats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 86,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final room = _filteredChats[index];
                  final unreadCount =
                      _unreadCounts[room.chatId] ?? 0;
                  final bool hasUnread = unreadCount > 0;

                  return InkWell(
                    onTap: () {
                      // Mark as read when tapped
                      setState(
                              () => _unreadCounts[room.chatId] = 0);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const DonationChatScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          DefaultAvatar(isOnline: room.isOnline),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.otherUserName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color:
                                    const Color(0xFF1A2E0A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  room.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasUnread
                                        ? const Color(0xFF1A2E0A)
                                        : Colors.grey.shade600,
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(room.lastMessageTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasUnread
                                      ? const Color(0xFF3A5C2E)
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (hasUnread)
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3A5C2E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}