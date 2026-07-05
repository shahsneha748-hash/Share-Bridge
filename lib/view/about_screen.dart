import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color kPrimary  = Color(0xFF2D5A27);
  static const Color kDark     = Color(0xFF1A3A15);
  static const Color kLight    = Color(0xFFF5F7F4);
  static const Color kCard     = Color(0xFFFFFFFF);
  static const Color kTextDark = Color(0xFF1C2B1A);
  static const Color kTextGrey = Color(0xFF7A8A78);
  static const Color kDivider  = Color(0xFFE8EDE7);

  static const String _appVersion = "1.2.0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLight,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
        title: const Text(
          "About Share Bridge",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── App identity card ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Share Bridge",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version $_appVersion",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Mission blurb ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Our Mission",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Share Bridge connects neighbors who have unused items with people who need them. "
                      "By making it simple to give, receive, and reduce waste, we're building stronger, "
                      "more generous communities — one shared item at a time.",
                  style: TextStyle(fontSize: 13, color: kTextGrey, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Info list ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                _infoTile(icon: Icons.info_outline, label: "App Version", value: _appVersion),
                const Divider(height: 1, indent: 64, color: kDivider),
                _infoTile(icon: Icons.calendar_today_outlined, label: "Founded", value: "2024"),
                const Divider(height: 1, indent: 64, color: kDivider),
                _actionTile(
                  icon: Icons.language,
                  label: "Website",
                  onTap: () {
                    // Wire up with url_launcher to your real site.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add your website URL here')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 64, color: kDivider),
                _actionTile(
                  icon: Icons.star_outline,
                  label: "Rate the App",
                  onTap: () {
                    // Wire up with url_launcher to your Play Store / App Store listing.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add your store listing URL here')),
                    );
                  },
                ),
                const Divider(height: 1, indent: 64, color: kDivider),
                _actionTile(
                  icon: Icons.share_outlined,
                  label: "Share This App",
                  onTap: () {
                    // Wire up with the share_plus package if you want native share sheet.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hook this up to share_plus')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "Made with care in Kathmandu, Nepal",
              style: TextStyle(fontSize: 12, color: kTextGrey.withOpacity(0.8)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: kTextGrey)),
        ],
      ),
    );
  }

  Widget _actionTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: kPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark)),
            ),
            const Icon(Icons.chevron_right, color: kTextGrey, size: 18),
          ],
        ),
      ),
    );
  }
}