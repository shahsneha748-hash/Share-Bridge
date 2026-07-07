import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../model/message_model.dart';
import '../components/quick_chip.dart';
import 'package:sharebridge/view/chat_contact_info_screen.dart';
import 'package:sharebridge/view/user_report_screen.dart';

class DonationChatScreen extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String itemName;

  const DonationChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.itemName,
  });

  static const Color _topBarColor = Color(0xFF2D5A14);
  static const Color _bgColor = Color(0xFFEDF0E8);
  static const Color _sentBubble = Color(0xFF4A7C26);
  static const Color _greenMedium = Color(0xFF4A7C26);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        chatId: chatId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        donationTitle: itemName,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Column(
          children: [
            Consumer<ChatViewModel>(
              builder: (context, vm, _) => _buildTopBar(context, vm),
            ),
            if (itemName.isNotEmpty) _buildBanner(context),
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, vm, _) => _buildMessageList(vm),
              ),
            ),
            Consumer<ChatViewModel>(
              builder: (context, vm, _) => _buildQuickReplies(vm),
            ),
            Consumer<ChatViewModel>(
              builder: (context, vm, _) => _buildInputBar(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  // ── CALL ──────────────────────────────────────────────
  Future<void> _makeCall(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) {
      _showSnackbar(context, "Phone number not available");
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        _showSnackbar(context, "Could not open dialer");
      }
    }
  }

  Widget _buildTopBar(BuildContext context, ChatViewModel vm) {
    return Container(
      color: _topBarColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              // Tappable avatar + name → opens contact info
              Expanded(
                child: InkWell(
                  onTap: () => _openContactInfo(context, vm),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF7AB648),
                        child: Text(
                          otherUserName.isNotEmpty
                              ? otherUserName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    otherUserName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (vm.isMuted) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.notifications_off,
                                      color: Colors.white70, size: 14),
                                ],
                              ],
                            ),
                            if ((vm.otherUserPhone ?? '').isNotEmpty)
                              Text(
                                vm.otherUserPhone!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () => _makeCall(context, vm.otherUserPhone),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _onMenuSelected(context, vm, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('View profile'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'mute',
                    child: ListTile(
                      leading: Icon(vm.isMuted
                          ? Icons.notifications_active
                          : Icons.notifications_off),
                      title: Text(vm.isMuted ? 'Unmute' : 'Mute chat'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: ListTile(
                      leading: Icon(Icons.flag),
                      title: Text('Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Opens the contact info screen
  void _openContactInfo(BuildContext context, ChatViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatContactInfoScreen(
          userId: otherUserId,
          userName: otherUserName,
          chatId: chatId,
          isMuted: vm.isMuted,
          onMuteChanged: (val) => vm.setMute(val),
        ),
      ),
    );
  }

  // Handles the 3-dot menu actions
  void _onMenuSelected(
      BuildContext context, ChatViewModel vm, String value) {
    switch (value) {
      case 'profile':
        _openContactInfo(context, vm);
        break;
      case 'mute':
        vm.toggleMute();
        _showSnackbar(
            context, vm.isMuted ? 'Chat muted' : 'Chat unmuted');
        break;
      case 'report':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserReportScreen()),
        );
        break;
    }
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.push_pin, size: 18, color: _greenMedium),
          const SizedBox(width: 6),
          const Text(
            "Re: ",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Expanded(
            child: Text(
              itemName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatViewModel vm) {
    return ListView.builder(
      controller: vm.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: vm.messages.length + 1 + (vm.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) return _buildDateSeparator("Today");
        final msgIndex = index - 1;
        if (vm.isTyping && msgIndex == vm.messages.length) {
          return _buildTypingBubble();
        }
        return _buildMessageBubble(vm.messages[msgIndex]);
      },
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final bool sent = msg.isSender;
    return Padding(
      padding: EdgeInsets.only(
        left: sent ? 56 : 8,
        right: sent ? 8 : 56,
        top: 2,
        bottom: 2,
      ),
      child: Align(
        alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: sent ? _sentBubble : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(sent ? 18 : 4),
              topRight: Radius.circular(sent ? 4 : 18),
              bottomLeft: const Radius.circular(18),
              bottomRight: const Radius.circular(18),
            ),
            boxShadow: [
              if (!sent)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  color: sent ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: sent
                          ? const Color(0xFFD4ECC0)
                          : const Color(0xFFAAB8A0),
                    ),
                  ),
                  if (sent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      msg.status == MessageStatus.read
                          ? Icons.done_all
                          : Icons.done,
                      size: 14,
                      color: msg.status == MessageStatus.read
                          ? const Color(0xFF90CAF9)
                          : const Color(0xFFD4ECC0),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            "typing . . .",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(ChatViewModel vm) {
    return Container(
      color: const Color.fromRGBO(255, 255, 255, 0.6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: vm.quickReplies
              .map(
                (text) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: QuickChip(
                text: text,
                onTap: () => vm.sendMessage(text),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatViewModel vm) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: vm.inputController,
                onSubmitted: vm.sendMessage,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: vm.inputController,
            builder: (_, value, __) {
              final canSend = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: canSend
                    ? () => vm.sendMessage(vm.inputController.text)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: canSend ? _greenMedium : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}