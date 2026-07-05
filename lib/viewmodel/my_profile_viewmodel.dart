import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/profile_display_data.dart';
import 'package:sharebridge/repo/profile_repo.dart';

class MyProfileViewModel extends ChangeNotifier {
  final ProfileRepo _profileRepo;

  MyProfileViewModel({required ProfileRepo profileRepo}) : _profileRepo = profileRepo;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ProfileDisplayData? _profile;
  ProfileDisplayData? get profile => _profile;

  Future<void> fetchProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _error = "No logged-in user";
        return;
      }
      _profile = await _profileRepo.getProfile(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}