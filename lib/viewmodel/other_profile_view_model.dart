import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/profile_display_data.dart';
import 'package:sharebridge/repo/block_repo.dart';
import 'package:sharebridge/repo/profile_repo.dart';

/// View-model for viewing *another* user's profile (read-only).
/// Mirrors MyProfileViewModel but has no upload/edit capabilities,
/// fetches by an explicit [uid] instead of the current user, and
/// additionally tracks whether the current user has this profile blocked.
class OtherProfileViewModel extends ChangeNotifier {
  final ProfileRepo _profileRepo;
  final BlockRepo _blockRepo;

  OtherProfileViewModel({
    required ProfileRepo profileRepo,
    required BlockRepo blockRepo,
  })  : _profileRepo = profileRepo,
        _blockRepo = blockRepo;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ProfileDisplayData? _profile;
  ProfileDisplayData? get profile => _profile;

  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  bool _blockActionInProgress = false;
  bool get blockActionInProgress => _blockActionInProgress;

  Future<void> fetchProfile(String uid) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final results = await Future.wait([
        _profileRepo.getProfile(uid),
        if (currentUid != null) _blockRepo.isBlocked(currentUid, uid),
      ]);

      final result = results[0] as ProfileDisplayData?;
      if (result == null) {
        _error = "User not found";
      }
      _profile = result;
      _isBlocked = currentUid != null ? (results.length > 1 ? results[1] as bool : false) : false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Returns true on success. [viewedUid] is the profile being viewed.
  Future<bool> toggleBlock(String viewedUid) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return false;

    _blockActionInProgress = true;
    notifyListeners();
    try {
      final success = _isBlocked
          ? await _blockRepo.unblockUser(currentUid, viewedUid)
          : await _blockRepo.blockUser(currentUid, viewedUid);
      if (success) {
        _isBlocked = !_isBlocked;
      }
      return success;
    } finally {
      _blockActionInProgress = false;
      notifyListeners();
    }
  }
}