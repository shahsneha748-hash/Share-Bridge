import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/create_donation_model.dart';
import '../repo/create_donation_repo.dart';
import '../repo/image_repo.dart';

class CreateDonationViewModel extends ChangeNotifier {
  final CreateDonationRepository _repo;
  final ImageRepo _imageRepo;

  CreateDonationViewModel(this._repo, this._imageRepo) {
    model.userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  CreateDonationModel model = CreateDonationModel();

  List<String> get images => model.images;

  bool loading = false;
  bool uploadingImage = false;

  // ================= CATEGORIES =================
  final List<Map<String, dynamic>> categories = const [
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'stationery', 'label': 'Stationery', 'icon': Icons.edit},
    {'id': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'id': 'other', 'label': 'Other', 'icon': Icons.category},
  ];

  // ================= CONDITIONS =================
  final List<String> conditions = const [
    'New',
    'Gently Used',
    'Used'
  ];

  // ================= GETTERS =================
  bool get isFood => model.category == 'food';

  // ================= SETTERS =================

  void setLocation(String value) {
    model.location = value;
    notifyListeners();
  }

  void setItemName(String value) {
    model.itemName = value;
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

    // reset subcategory when category changes
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
    model.images =
        model.images.where((img) => img != imageUrl).toList();
    notifyListeners();
  }

  // ================= VALIDATION =================

  bool get canSubmit {
    return model.location.isNotEmpty &&
        model.itemName.isNotEmpty &&
        model.category.isNotEmpty &&
        model.condition.isNotEmpty;
  }

  // ================= SUBMIT =================

  Future<bool> submit() async {
    loading = true;
    notifyListeners();

    bool success = false;

    try {
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