import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const Color kPrimary  = Color(0xFF2D5A27);
  static const Color kLight    = Color(0xFFF5F7F4);
  static const Color kCard     = Color(0xFFFFFFFF);
  static const Color kTextDark = Color(0xFF1C2B1A);
  static const Color kTextGrey = Color(0xFF7A8A78);

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Getting Started',
      'items': [
        {
          'q': 'How do I share an item?',
          'a': 'Tap the "Post" button in the center of the bottom navigation bar, add a photo, title, category, and description, then submit. Your item becomes visible to nearby community members right away.',
        },
        {
          'q': 'How do I request an item someone else posted?',
          'a': 'Open the item from the Browse tab and tap "Request". The owner will be notified and can approve or decline your request.',
        },
      ],
    },
    {
      'title': 'Donations & Items',
      'items': [
        {
          'q': 'How is my donation count calculated?',
          'a': 'Your donation count increases each time an item you\'ve shared is successfully picked up by another community member.',
        },
        {
          'q': 'Can I edit or delete an item after posting it?',
          'a': 'Yes. Go to "My Items", select the item, and use the edit or delete option. Items already claimed by someone else can\'t be edited.',
        },
        {
          'q': 'What happens if the person I donated to doesn\'t respond?',
          'a': 'If there\'s no response within a few days, the request automatically expires and the item becomes available to others again.',
        },
      ],
    },
    {
      'title': 'Account & Trust',
      'items': [
        {
          'q': 'What does "Verified" mean next to my name?',
          'a': 'A verified badge means your identity or contact details have been confirmed, which helps build trust with other community members.',
        },
        {
          'q': 'How is my rating calculated?',
          'a': 'Your rating is the average of feedback left by people you\'ve donated to or received items from.',
        },
        {
          'q': 'How do I report a user?',
          'a': 'Open their profile and tap the report icon, or contact support below with details of the issue.',
        },
      ],
    },
    {
      'title': 'Privacy & Safety',
      'items': [
        {
          'q': 'Is my location shared with everyone?',
          'a': 'Only your general area (e.g. city) is shown publicly. Your exact address is never shared unless you choose to reveal it during an exchange.',
        },
        {
          'q': 'How do I stay safe when meeting someone to exchange items?',
          'a': 'Always meet in a public place, let someone know where you\'re going, and avoid sharing sensitive personal information in chat.',
        },
      ],
    },
  ];

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
          "Help & FAQ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._sections.map((section) => _buildSection(section)),
          const SizedBox(height: 8),
          _buildContactCard(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              section['title'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kTextGrey,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: Column(
                children: (section['items'] as List).asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value as Map<String, String>;
                  final isLast = i == (section['items'] as List).length - 1;
                  return Column(
                    children: [
                      ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        expandedAlignment: Alignment.topLeft,
                        iconColor: kPrimary,
                        collapsedIconColor: kTextGrey,
                        title: Text(
                          item['q']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
                        ),
                        children: [
                          Text(
                            item['a']!,
                            style: const TextStyle(fontSize: 13, color: kTextGrey, height: 1.4),
                          ),
                        ],
                      ),
                      if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE8EDE7)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Still need help?",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  "Reach out and we'll get back to you.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Wire this to your support email, in-app chat, or a contact form.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact support — hook this up to your support channel')),
              );
            },
            style: TextButton.styleFrom(backgroundColor: Colors.white),
            child: const Text("Contact", style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}