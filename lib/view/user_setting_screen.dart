import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';
import 'help_faq_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';




class UserSettingsScreen extends StatelessWidget {
  const UserSettingsScreen({super.key});

  static const Color kPrimary  = Color(0xFF2D5A27);
  static const Color kLight    = Color(0xFFF5F7F4);
  static const Color kCard     = Color(0xFFFFFFFF);
  static const Color kTextDark = Color(0xFF1C2B1A);
  static const Color kTextGrey = Color(0xFF7A8A78);
  static const Color kDivider  = Color(0xFFE8EDE7);

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Adjust '/login' to match your actual login route name.
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This will permanently delete your account and profile data. This cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Remove Firestore profile document.
      await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
      // 2. Remove the Firebase Auth account itself.
      await user.delete();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please log out and log back in, then try deleting your account again."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account: ${e.message}")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    }
  }

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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard([
            _tile(
              icon: Icons.person_outline,
              label: "Edit Profile",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
            ),
            _tile(
              icon: Icons.notifications_outlined,
              label: "Notifications",
              onTap: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard([
            _tile(icon: Icons.help_outline, label: "Help & FAQ", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen()));

            }),
            _tile(icon: Icons.privacy_tip_outlined, label: "Privacy Policy", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));

            }),
            _tile(icon: Icons.info_outline, label: "About Share Bridge", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));

            }),
          ]),
          const SizedBox(height: 16),
          _sectionCard([
            _tile(
              icon: Icons.logout,
              label: "Log Out",
              labelColor: Colors.red.shade600,
              iconColor: Colors.red.shade600,
              onTap: () => _confirmLogout(context),
            ),
            _tile(
              icon: Icons.delete_outline,
              label: "Delete Account",
              labelColor: Colors.red.shade600,
              iconColor: Colors.red.shade600,
              onTap: () => _confirmDeleteAccount(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) const Divider(height: 1, indent: 64, color: kDivider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? kPrimary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? kPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelColor ?? kTextDark),
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextGrey, size: 18),
          ],
        ),
      ),
    );
  }
}