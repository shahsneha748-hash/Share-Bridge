import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';

class VolunteerViewModel extends ChangeNotifier {
  final VolunteerRepo repo;

  VolunteerViewModel(this.repo);

  Future<String> getStatus(String userId) async {
    return await repo.getStatus(userId);
  }

  Stream<String> watchStatus(String userId) {
    return repo.getStatusStream(userId);
  }

  bool canAccess(String status) {
    return status == "Approved";
  }

  final ImagePicker picker = ImagePicker();

  XFile? citizenshipImage;
  XFile? selfieImage;

  String? vehicle;
  String? availability;
  String? errorMessage;

  String? getMissingFieldMessage(
      String citizenshipNumber,
      bool agreed,
      ) {
    if (citizenshipNumber.isEmpty) {
      return "Please enter citizenship number";
    }

    if (citizenshipImage == null) {
      return "Please upload citizenship document";
    }

    if (selfieImage == null) {
      return "Please take a selfie";
    }

    if (!agreed) {
      return "Please accept the declaration checkbox";
    }

    return null;
  }

  bool loading = false;

  bool get isFormValid {
    return citizenshipImage != null &&
        selfieImage != null &&
        citizenshipImage!.path.isNotEmpty &&
        selfieImage!.path.isNotEmpty;
  }

  bool get isFullyValid {
    return citizenshipImage != null &&
        selfieImage != null &&
        vehicle != null &&
        availability != null &&
        citizenshipImage!.path.isNotEmpty &&
        selfieImage!.path.isNotEmpty;
  }

  bool canAccessVolunteer(String status) {
    return status == "Approved";
  }

  // ---------------- PICK DOCUMENT ----------------

  Future<void> pickCitizenship(ImageSource source) async {
    final img = await picker.pickImage(source: source);

    if (img != null) {
      citizenshipImage = img;
      notifyListeners();
    }
  }

  // ---------------- SELFIE (CAMERA ONLY) ----------------

  Future<void> takeSelfie() async {
    final img = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (img != null) {
      selfieImage = img;
      notifyListeners();
    }
  }

  // ---------------- SETTERS ----------------

  void setVehicle(String value) {
    vehicle = value;
    notifyListeners();
  }

  void setAvailability(String value) {
    availability = value;
    notifyListeners();
  }

  // ---------------- SUBMIT ----------------

  Future<void> submit({
    required String userId,
    required String citizenshipNumber,
  }) async {
    if (!isFormValid) {
      throw Exception("Form incomplete");
    }

    loading = true;
    notifyListeners();

    final model = VolunteerModel(
      userId: userId,
      citizenshipNumber: citizenshipNumber,
      citizenshipImage: citizenshipImage?.path ?? "",
      selfieImage: selfieImage?.path ?? "",
      vehicle: vehicle ??"",
      availability: availability ??"",
      status: "Pending",
      submittedAt: DateTime.now(),
    );

    await repo.submitVolunteer(model);

    loading = false;
    notifyListeners();
  }
}