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

    // Replace with Firestore later:
    // final doc = await FirebaseFirestore.instance
    //     .collection('admins').doc(currentUserId).get();
    // _profile = AdminProfile.fromMap(doc.data()!);
    await Future.delayed(const Duration(milliseconds: 500));

    _profile = AdminProfile(
      name: 'Admin User',
      email: 'admin@sharebridge.com',
      initials: 'AU',
      role: 'Super Admin',
      joinDate: 'Jan 2024',
    );

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
    // Replace with Firebase Auth later:
    // await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 300));
  }
}