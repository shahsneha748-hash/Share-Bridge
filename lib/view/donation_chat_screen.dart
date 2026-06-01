import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../model/message_model.dart';
import '../components/quick_chip.dart';

class DonationChatScreen extends StatelessWidget {
  const DonationChatScreen({super.key});

  static const Color _topBarColor = Color(0xFF2D5A14);
  static const Color _bgColor = Color(0xFFEDF0E8);
  static const Color _sentBubble = Color(0xFF4A7C26);
  static const Color _greenMedium = Color(0xFF4A7C26);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Column(
          children: [
            _buildTopBar(context),
            _buildBanner(context),
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

  Widget _buildTopBar(BuildContext context) {
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
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF7AB648),
                child: Text(
                  "R",
                  style: TextStyle(
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
                    const Text(
                      "Ram Sah",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF56C769),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () => _showSnackbar(context, "Starting voice call with Ram Sah…"),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _showSnackbar(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "Opening Ram Sah's profile",
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text("View profile"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: "Chat muted",
                    child: ListTile(
                      leading: Icon(Icons.notifications_off),
                      title: Text("Mute chat"),
                    ),
                  ),
                  const PopupMenuItem(
                    value: "Report submitted",
                    child: ListTile(
                      leading: Icon(Icons.flag),
                      title: Text("Report"),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: "Conversation deleted",
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        "Delete conversation",
                        style: TextStyle(color: Colors.red),
                      ),
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

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDonationDetail(context),
      child: Container(
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
            const Expanded(
              child: Text(
                "Grocery Essentials Bundle",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD7EDCA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Food",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2D6E10),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: Color(0xFF9E8A6A)),
                  SizedBox(width: 3),
                  Text(
                    "Exp 2d",
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E8A6A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EDCA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Food",
                    style: TextStyle(
                      color: Color(0xFF2D6E10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Grocery Essentials Bundle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow("Pickup Deadline", "Today before 6:00 PM"),
            const SizedBox(height: 12),
            _detailRow("Pickup Location", "Imadol 5, near ABC Tol gate"),
            const SizedBox(height: 12),
            _detailRow(
              "Description",
              "A bundle of essential grocery items including rice, lentils, "
                  "cooking oil, and canned goods. Perfect for a family of 4 for about a week.",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _greenMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
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
                    msg.timestamp,
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
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () => _showAttachmentSheet(context),
          ),
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
                onTap: canSend ? () => vm.sendMessage(vm.inputController.text) : null,
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

  void _showAttachmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Share",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachOption(ctx, "📷", "Camera"),
                _attachOption(ctx, "🖼️", "Gallery"),
                _attachOption(ctx, "📍", "Location"),
                _attachOption(ctx, "📄", "Document"),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _attachOption(BuildContext ctx, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        _showSnackbar(ctx, "$label opened");
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
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