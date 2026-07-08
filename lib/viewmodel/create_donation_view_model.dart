import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/service/notification_service.dart';

import '../model/create_donation_model.dart';
import '../repo/create_donation_repo.dart';
import '../repo/image_repo.dart';

class CreateDonationViewModel extends ChangeNotifier {
  final CreateDonationRepository _repo;
  final ImageRepo _imageRepo;

  CreateDonationViewModel(this._repo, this._imageRepo) {
    model.userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    model.donorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    model.id = DateTime.now().millisecondsSinceEpoch.toString();  }

  CreateDonationModel model = CreateDonationModel();

  List<String> get images => model.images;

  bool loading = false;
  bool uploadingImage = false;

  // ================= DONOR INFO (resolved right before submit) =================

  /// Fetches the current user's fullName/rating/totalDonations from
  /// Firestore `users` collection and stamps them onto the donation model.
  /// Tries doc-id-as-uid first, then falls back to querying by an 'id' field,
  /// so it works regardless of how the users collection was structured.
  Future<void> _ensureDonorInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    model.userId = user.uid;
    model.donorId = user.uid;

    try {
      Map<String, dynamic>? data;

      // 1st try: assume the Firestore doc ID IS the auth uid.
      final directDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (directDoc.exists) {
        data = directDoc.data();
        debugPrint('✅ Found user doc by direct id: ${user.uid}');
      } else {
        // 2nd try: doc ID is random, but there's an 'id' field matching the uid.
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          data = query.docs.first.data();
          debugPrint('✅ Found user doc by id field query: ${user.uid}');
        }
      }

      if (data != null) {
        final fullName = data['fullName'] as String?;
        if (fullName != null && fullName.trim().isNotEmpty) {
          model.donorName = fullName;
        }
        model.donorRating = (data['rating'] as num?)?.toDouble() ?? model.donorRating;
        model.donorDonations = (data['totalDonations'] as num?)?.toInt() ?? model.donorDonations;
      } else {
        debugPrint('⚠️ No matching users document found for uid=${user.uid}');
      }
    } catch (e) {
      debugPrint('Failed to load donor profile: $e');
    }

    // Fallbacks so it's never literally "Unknown" even if the users doc is missing.
    if (model.donorName.trim().isEmpty || model.donorName == 'Unknown') {
      model.donorName = user.displayName ??
          (user.email != null ? user.email!.split('@').first : 'Donor');
    }

    debugPrint('🏁 Final donorName resolved to: ${model.donorName}');
  }

  // ================= CATEGORIES =================
  final List<Map<String, dynamic>> categories = const [
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'stationery', 'label': 'Stationery', 'icon': Icons.edit},
    {'id': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'id': 'other', 'label': 'Other', 'icon': Icons.category},
  ];

  // ================= CONDITIONS =================
  final List<String> conditions = const ['New', 'Gently Used', 'Used'];

  // ================= GETTERS =================
  bool get isFood => model.category == 'food';
  bool get showConditionField {
    return model.category != 'food';
  }

  // ================= SETTERS =================

  void setLocation(String value) {
    model.location = value;
    notifyListeners();
  }

  void setCoordinates(double lat, double lng) {
    model.mapLat = lat;
    model.mapLng = lng;
    notifyListeners();
  }

  void setItemName(String value) {
    model.itemName = value;
    model.title = value; // keep title in sync with itemName
    notifyListeners();
  }

  void setDescription(String value) {
    model.description = value;
    notifyListeners();
  }

  void setExpiry(String value) {
    model.expiryDate = value;
    notifyListeners();
  }

  void setCategory(String value) {
    model.category = value;
    model.subcategory = '';
    notifyListeners();
  }

  void setSubcategory(String value) {
    model.subcategory = value;
    notifyListeners();
  }

  void setCondition(String value) {
    model.condition = value;
    notifyListeners();
  }

  void setUnit(String value) {
    model.unit = value;
    notifyListeners();
  }

  void setWeight(String value) {
    model.weight = value;
    notifyListeners();
  }

  void setNote(String value) {
    model.note = value;
    notifyListeners();
  }

  void toggleDonation() {
    model.isDonated = !model.isDonated;
    notifyListeners();
  }

  // ================= PORTION =================

  void incrementPortion() {
    model.portionCount++;
    notifyListeners();
  }

  void decrementPortion() {
    if (model.portionCount > 1) {
      model.portionCount--;
      notifyListeners();
    }
  }

  // ================= TAGS =================

  void addTag(String tag) {
    if (tag.trim().isEmpty) return;
    model.tags = [...model.tags, tag.trim()];
    notifyListeners();
  }

  void removeTag(String tag) {
    model.tags = model.tags.where((t) => t != tag).toList();
    notifyListeners();
  }

  // ================= IMAGE UPLOAD =================

  Future<void> addImage(String filePath) async {
    if (model.images.length >= 5) return;

    uploadingImage = true;
    notifyListeners();

    try {
      final url = await _imageRepo.uploadImage(filePath);
      model.images.add(url);
    } catch (e) {
      debugPrint("Image upload error: $e");
    }

    uploadingImage = false;
    notifyListeners();
  }

  void removeImage(String imageUrl) {
    model.images = model.images.where((img) => img != imageUrl).toList();
    notifyListeners();
  }

  // ================= VALIDATION =================

  bool get canSubmit {
    final conditionOk = isFood || model.condition.isNotEmpty;
    return model.location.isNotEmpty &&
        model.itemName.isNotEmpty &&
        model.category.isNotEmpty &&
        conditionOk;
  }

  // ================= SUBMIT =================

  Future<bool> submit() async {
    if (!canSubmit) {
      return false;
    }

    loading = true;
    notifyListeners();

    bool success = false;

    try {
      await _ensureDonorInfo();

      success = await _repo.submitDonation(model);

      // 👇 ADD HERE
      if (success && isFood && model.expiryDate.isNotEmpty) {
        await NotificationService.scheduleExpiryNotifications(
          itemName: model.itemName,
          expiryDate: model.expiryDate,
          donationId: model.userId,
        );
      }

    } catch (e) {
      debugPrint("Submit error: $e");
      success = false;
    }

    loading = false;
    notifyListeners();

    return success;
  }

  // ================= SUBMIT =================


}