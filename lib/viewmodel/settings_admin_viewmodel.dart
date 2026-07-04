import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/settings_admin_model.dart';

class SettingsAdminViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _emailAlertsEnabled = true;
  bool _flaggedContentAlerts = true;

  AdminProfile? _profile;

  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailAlertsEnabled => _emailAlertsEnabled;
  bool get flaggedContentAlerts => _flaggedContentAlerts;
  AdminProfile? get profile => _profile;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final data = doc.data();
        final name = data?['fullName'] as String? ?? data?['fullname'] as String? ?? 'Admin User';
        final email = data?['email'] as String? ??
            currentUser.email ?? 'admin@sharebridge.com';

        _profile = AdminProfile(
          name: name,
          email: email,
          initials: name.isNotEmpty ? name[0].toUpperCase() : 'A',
          role: 'Super Admin',
          joinDate: 'Jan 2024',
        );
      } else {
        // Fallback if not logged in (for testing)
        _profile = AdminProfile(
          name: 'Admin User',
          email: 'admin@sharebridge.com',
          initials: 'AU',
          role: 'Super Admin',
          joinDate: 'Jan 2024',
        );
      }
    } catch (e) {
      debugPrint('Error loading admin profile: $e');
      _profile = AdminProfile(
        name: 'Admin User',
        email: 'admin@sharebridge.com',
        initials: 'AU',
        role: 'Super Admin',
        joinDate: 'Jan 2024',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleEmailAlerts(bool value) {
    _emailAlertsEnabled = value;
    notifyListeners();
  }

  void toggleFlaggedAlerts(bool value) {
    _flaggedContentAlerts = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}