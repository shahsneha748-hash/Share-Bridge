import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color kPrimary  = Color(0xFF2D5A27);
  static const Color kLight    = Color(0xFFF5F7F4);
  static const Color kCard     = Color(0xFFFFFFFF);
  static const Color kTextDark = Color(0xFF1C2B1A);
  static const Color kTextGrey = Color(0xFF7A8A78);

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Introduction',
      'body': 'Share Bridge ("we", "our", "the app") connects people who want to donate unused items with people who need them. This policy explains what information we collect, how we use it, and the choices you have.',
    },
    {
      'title': '2. Information We Collect',
      'body': 'When you create an account, we collect your name, email address, phone number, and general location. When you post or request items, we collect the details of those listings (title, category, description, photos) and your activity within the app, such as donations made and items saved.',
    },
    {
      'title': '3. How We Use Your Information',
      'body': 'We use your information to operate core features of the app: showing your profile to other users, matching you with nearby items, calculating your donation count and rating, sending you notifications about requests or messages, and improving the app\'s functionality over time.',
    },
    {
      'title': '4. Location Data',
      'body': 'Your general area (such as your city) is shown publicly to help match you with nearby donations. Your exact address is never shared with other users unless you choose to reveal it, for example when arranging to meet for an exchange.',
    },
    {
      'title': '5. Sharing With Other Users',
      'body': 'Certain profile details are visible to other users, including your name, profile picture, general location, rating, and verification status. This is necessary for a community-based sharing platform to function and build trust between members.',
    },
    {
      'title': '6. Data Security',
      'body': 'We store your data using Firebase (Google Cloud), which provides industry-standard security practices including encryption in transit. While we take reasonable steps to protect your data, no system can guarantee complete security.',
    },
    {
      'title': '7. Your Rights & Choices',
      'body': 'You can update your profile information at any time from Edit Profile. You can control device-level notification permissions from Settings. You may request deletion of your account and associated data through the Delete Account option in Settings.',
    },
    {
      'title': '8. Data Retention',
      'body': 'We retain your account information for as long as your account is active. If you delete your account, your profile data is permanently removed, though some records (such as completed transaction history) may be retained as required for safety or legal purposes.',
    },
    {
      'title': '9. Children\'s Privacy',
      'body': 'Share Bridge is not intended for use by children under the age of 13 (or the minimum age required in your region). We do not knowingly collect personal information from children.',
    },
    {
      'title': '10. Changes to This Policy',
      'body': 'We may update this privacy policy from time to time. Continued use of the app after changes are posted constitutes acceptance of the revised policy.',
    },
    {
      'title': '11. Contact Us',
      'body': 'If you have questions about this privacy policy or how your data is handled, please reach out through the Contact option in Help & FAQ.',
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
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const Text(
              "Last updated: July 2026",
              style: TextStyle(fontSize: 12, color: kTextGrey, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
          ..._sections.map((s) => _buildSection(s)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, String> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
            Text(
              section['title']!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
            ),
            const SizedBox(height: 8),
            Text(
              section['body']!,
              style: const TextStyle(fontSize: 13, color: kTextGrey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}