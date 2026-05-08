import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum MessageStatus { sent, delivered, read }

class Message {
  final int id;
  final String text;
  final bool isSender;
  final String timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isSender,
    required this.timestamp,
    this.status = MessageStatus.read,
  });
}

class DonationChatScreen extends StatefulWidget {
  const DonationChatScreen({super.key});

  @override
  State<DonationChatScreen> createState() => _DonationChatScreenState();
}

class _DonationChatScreenState extends State<DonationChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  int _idCounter = 5;

  final List<String> _quickReplies = [
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

  final List<Message> _messages = [
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
      text: "You can pick it up today before 6pm at Imadol 5, near ABC Tol gate. I'll be home all afternoon.",
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

  static const Color _topBarColor = Color(0xFF2D5A14);
  static const Color _bgColor     = Color(0xFFEDF0E8);
  static const Color _sentBubble  = Color(0xFF4A7C26);
  static const Color _greenMedium = Color(0xFF4A7C26);

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;
    final m    = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $amPm';
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(Message(
        id: ++_idCounter,
        text: text.trim(),
        isSender: true,
        timestamp: _currentTime(),
        status: MessageStatus.sent,
      ));
    });
    _inputController.clear();
    _scrollToBottom();
    _simulateBotReply();
  }

  void _simulateBotReply() {
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isTyping = true);
      _scrollToBottom();
      Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(Message(
            id: ++_idCounter,
            text: _botReplies[Random().nextInt(_botReplies.length)],
            isSender: false,
            timestamp: _currentTime(),
          ));
        });
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildTopBar(),
          _buildBanner(),
          Expanded(child: _buildMessageList()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
                onPressed: () =>
                    _showSnackbar("Starting voice call with Ram Sah…"),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _showSnackbar(value),
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

  Widget _buildBanner() {
    return GestureDetector(
      onTap: _showDonationDetail,
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

  void _showDonationDetail() {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                  "cooking oil, and canned goods. Perfect for a family of 4 "
                  "for about a week.",
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

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length + 1 + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) return _buildDateSeparator("Today");
        final msgIndex = index - 1;
        if (_isTyping && msgIndex == _messages.length) {
          return _buildTypingBubble();
        }
        return _buildMessageBubble(_messages[msgIndex]);
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

  Widget _buildQuickReplies() {
    return Container(
      color: const Color.fromRGBO(255, 255, 255, 0.6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: _quickReplies
              .map(
                (text) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickChip(
                text: text,
                onTap: () => _sendMessage(text),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
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
            onPressed: _showAttachmentSheet,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                onSubmitted: _sendMessage,
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
            valueListenable: _inputController,
            builder: (_, value, __) {
              final canSend = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: canSend
                    ? () => _sendMessage(_inputController.text)
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

  void _showAttachmentSheet() {
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
        _showSnackbar("$label opened");
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
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK CHIP WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _QuickChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickChip({required this.text, required this.onTap});

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB8C8B0)),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}