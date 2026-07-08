import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // NEW: for fallback address→lat/lng

import '../model/create_donation_model.dart';
import '../repo/create_donation_repo.dart';
import '../repo/image_repo.dart';

class CreateDonationViewModel extends ChangeNotifier {
  final CreateDonationRepository _repo;
  final ImageRepo _imageRepo;

  CreateDonationViewModel(this._repo, this._imageRepo) {
    model.userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    model.donorId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  CreateDonationModel model = CreateDonationModel();

  List<String> get images => model.images;

  bool loading = false;
  bool uploadingImage = false;

  // ================= DONOR INFO (resolved right before submit) =================

  Future<void> _ensureDonorInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    model.userId = user.uid;
    model.donorId = user.uid;

    try {
      Map<String, dynamic>? data;

      final directDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (directDoc.exists) {
        data = directDoc.data();
        debugPrint('✅ Found user doc by direct id: ${user.uid}');
      } else {
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

    if (model.donorName.trim().isEmpty || model.donorName == 'Unknown') {
      model.donorName = user.displayName ??
          (user.email != null ? user.email!.split('@').first : 'Donor');
    }

    debugPrint('🏁 Final donorName resolved to: ${model.donorName}');
  }

  Future<void> _ensureCoordinates() async {
    if (model.mapLat != null && model.mapLng != null) {
      // Already captured via GPS button or map picker — nothing to do.
      return;
    }
    if (model.location.trim().isEmpty) return;

    try {
      final results = await locationFromAddress(model.location);
      if (results.isNotEmpty) {
        model.mapLat = results.first.latitude;
        model.mapLng = results.first.longitude;
        debugPrint('📍 Geocoded "${model.location}" → ${model.mapLat}, ${model.mapLng}');
      } else {
        debugPrint('⚠️ Geocoding returned no results for "${model.location}"');
      }
    } catch (e) {
      // Geocoding can fail (no internet, address not found, API limits).
      // We deliberately do NOT block submission on this — better to post
      // the donation without coordinates than to lose it entirely.
      debugPrint('⚠️ Geocoding failed for "${model.location}": $e');
    }
  }

  // ================= CATEGORIES =================
  final List<Map<String, dynamic>> categories = const [
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'stationery', 'label': 'Stationery', 'icon': Icons.edit},
    {'id': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'id': 'other', 'label': 'Other', 'icon': Icons.category},
  ];

  final List<String> conditions = const ['New', 'Gently Used', 'Used'];

  bool get isFood => model.category == 'food';
  bool get showConditionField {
    return model.category != 'food';
  }


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
    model.title = value;
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

  void addTag(String tag) {
    if (tag.trim().isEmpty) return;
    model.tags = [...model.tags, tag.trim()];
    notifyListeners();
  }

  void removeTag(String tag) {
    model.tags = model.tags.where((t) => t != tag).toList();
    notifyListeners();
  }

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

  bool get canSubmit {
    return model.location.isNotEmpty &&
        model.itemName.isNotEmpty &&
        model.category.isNotEmpty &&
        model.condition.isNotEmpty;
  }
  Future<bool> submit() async {
    loading = true;
    notifyListeners();

    bool success = false;

    try {
      await _ensureDonorInfo();
      await _ensureCoordinates(); // NEW: geocode fallback before writing to Firestore
      success = await _repo.submitDonation(model);
    } catch (e) {
      debugPrint("Submit error: $e");
      success = false;
    }

    loading = false;
    notifyListeners();

    return success;
  }
}