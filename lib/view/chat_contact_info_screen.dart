import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sharebridge/view/user_report_screen.dart';

class ChatContactInfoScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String chatId;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  const ChatContactInfoScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.chatId,
    required this.isMuted,
    required this.onMuteChanged,
  });

  @override
  State<ChatContactInfoScreen> createState() =>
      _ChatContactInfoScreenState();
}

class _ChatContactInfoScreenState extends State<ChatContactInfoScreen> {
  static const Color _green = Color(0xFF2D5A14);
  static const Color _bg = Color(0xFFEDF0E8);

  Map<String, dynamic>? _userData;
  bool _loading = true;
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _muted = widget.isMuted;
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      setState(() {
        _userData = doc.data();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _call(String? phone) async {
    if (phone == null || phone.isEmpty) {
      _snack('Phone number not available');
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open dialer');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _userData?['fullName'] ?? widget.userName;
    final phone = _userData?['phone'] ?? '';
    final email = _userData?['email'] ?? '';
    final address = _userData?['address'] ?? '';
    final rating = _userData?['rating'] ?? 0;
    final totalDonations = _userData?['totalDonations'] ?? 0;
    final profilePic = _userData?['profilePicture'];
    final hasPic = profilePic != null && profilePic.toString().isNotEmpty;

    return Scaffold(
      backgroundColor: _bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _green,
            pinned: true,
            expandedHeight: 260,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _green,
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF7AB648),
                      backgroundImage:
                      hasPic ? NetworkImage(profilePic) : null,
                      child: hasPic
                          ? null
                          : Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(phone,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Action buttons: Message + Call
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Message',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.call,
                        label: 'Call',
                        onTap: () => _call(phone),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info card
              _infoCard([
                if (email.isNotEmpty)
                  _infoRow(Icons.email_outlined, 'Email', email),
                if (address.isNotEmpty)
                  _infoRow(Icons.location_on_outlined, 'Address',
                      address),
                _infoRow(Icons.star_outline, 'Rating',
                    '${(rating as num).toStringAsFixed(1)} ★'),
                _infoRow(Icons.volunteer_activism_outlined,
                    'Donations', '$totalDonations items shared'),
              ]),

              const SizedBox(height: 16),

              // Mute toggle
              _settingCard(
                child: SwitchListTile(
                  value: _muted,
                  activeColor: _green,
                  secondary: Icon(
                    _muted
                        ? Icons.notifications_off
                        : Icons.notifications_active_outlined,
                    color: _green,
                  ),
                  title: const Text('Mute notifications'),
                  subtitle: Text(_muted
                      ? 'You won\'t get notified'
                      : 'Notifications on'),
                  onChanged: (val) {
                    setState(() => _muted = val);
                    widget.onMuteChanged(val);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Report
              _settingCard(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined,
                      color: Colors.red),
                  title: const Text('Report',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const UserReportScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: _green, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _green),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}