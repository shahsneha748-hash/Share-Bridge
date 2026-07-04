import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/components/default_avatar.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/view/donation_chat_screen.dart';
import 'package:sharebridge/viewmodel/chat_list_view_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(),
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  Widget _filterChip(
      BuildContext context,
      String label,
      String selectedFilter,
      int? badge,
      ) {
    final bool active = selectedFilter == label;
    final vm = context.read<ChatListViewModel>();
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color:
                active ? Colors.white : const Color(0xFF3A5C2E),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 5),
              Text(
                '$badge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Colors.white
                      : const Color(0xFF3A5C2E),
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
    final vm = context.watch<ChatListViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                    const Icon(Icons.search,
                        color: Colors.grey, size: 21),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              color: Colors.grey, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: vm.setSearchQuery,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── FILTER CHIPS ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip(
                      context, 'All', vm.selectedFilter, null),
                  _filterChip(context, 'Unread', vm.selectedFilter,
                      vm.totalUnreadChats),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── CHAT LIST ─────────────────────────────────────────────
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.filteredChats.isEmpty
                  ? const Center(
                child: Text(
                  'No conversations found',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 15),
                ),
              )
                  : ListView.separated(
                padding:
                const EdgeInsets.symmetric(vertical: 8),
                itemCount: vm.filteredChats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 86,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final room = vm.filteredChats[index];
                  final unreadCount =
                      vm.unreadCounts[room.chatId] ?? 0;
                  final bool hasUnread = unreadCount > 0;

                  return InkWell(
                    onTap: () {
                      vm.markAsRead(room.chatId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonationChatScreen(
                            chatId: room.chatId,
                            donorId: room.donorId,
                            donorName: room.otherUserName,
                            itemName: room.donationTitle,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          DefaultAvatar(
                              isOnline: room.isOnline),
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
                                    color: const Color(
                                        0xFF1A2E0A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  room.lastMessage,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasUnread
                                        ? const Color(
                                        0xFF1A2E0A)
                                        : Colors.grey
                                        .shade600,
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
                                vm.formatTime(
                                    room.lastMessageTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasUnread
                                      ? const Color(
                                      0xFF3A5C2E)
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (hasUnread)
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration:
                                  const BoxDecoration(
                                    color: Color(0xFF3A5C2E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.bold,
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