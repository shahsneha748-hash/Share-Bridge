import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/profile_display_data.dart';
import 'package:sharebridge/repo/profile_repo.dart';
import 'package:sharebridge/repo/image_repo.dart';

class MyProfileViewModel extends ChangeNotifier {
  final ProfileRepo _profileRepo;
  final ImageRepo _imageRepo;

  MyProfileViewModel({
    required ProfileRepo profileRepo,
    required ImageRepo imageRepo,
  })  : _profileRepo = profileRepo,
        _imageRepo = imageRepo;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ProfileDisplayData? _profile;
  ProfileDisplayData? get profile => _profile;

  bool _uploadingPhoto = false;
  bool get uploadingPhoto => _uploadingPhoto;

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

  Future<void> updateProfilePicture(String filePath) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _uploadingPhoto = true;
    notifyListeners();

    try {
      final url = await _imageRepo.uploadImage(filePath);
      final success = await _profileRepo.updateProfilePicture(uid, url);

      if (success && _profile != null) {
        _profile = _profile!.copyWith(profilePicture: url);
      }
    } catch (e) {
      debugPrint("Error updating profile picture: $e");
    } finally {
      _uploadingPhoto = false;
      notifyListeners();
    }
  }
}