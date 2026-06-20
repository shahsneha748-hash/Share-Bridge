import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/report_model.dart';

class ReportController extends ChangeNotifier {
  String selectedType   = '';
  String selectedReason = '';
  bool isAnonymous      = false;
  bool isSubmitting     = false;
  File? attachedImage;

  final TextEditingController detailsController = TextEditingController();
  int charCount = 0;

  ReportController() {
    detailsController.addListener(() {
      charCount = detailsController.text.length;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  // Check if form is valid to submit
  bool get canSubmit =>
      selectedType.isNotEmpty &&
          selectedReason.isNotEmpty &&
          charCount >= 15;

  // Get the selected report type data
  ReportType? get selectedTypeData {
    try {
      return reportTypes.firstWhere((t) => t.label == selectedType);
    } catch (_) {
      return null;
    }
  }

  void selectType(String type) {
    selectedType = type;
    notifyListeners();
  }

  void selectReason(String reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void toggleAnonymous(bool value) {
    isAnonymous = value;
    notifyListeners();
  }

  void removeImage() {
    attachedImage = null;
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Attach Evidence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3DE),
                child: Icon(Icons.photo_library, color: Color(0xFF4A7C26)),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) {
                  attachedImage = File(picked.path);
                  notifyListeners();
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3DE),
                child: Icon(Icons.camera_alt, color: Color(0xFF4A7C26)),
              ),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
                if (picked != null) {
                  attachedImage = File(picked.path);
                  notifyListeners();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Submit the report — replace Future.delayed with Firestore later
  Future<bool> submitReport() async {
    if (!canSubmit) return false;

    isSubmitting = true;
    notifyListeners();

    // Simulate network call — replace with Firestore when ready:
    // await FirebaseFirestore.instance.collection('reports').add(
    //   ReportSubmission(...).toMap()
    // );
    await Future.delayed(const Duration(seconds: 2));

    isSubmitting = false;
    notifyListeners();
    return true;
  }

  // Reset form after submission
  void resetForm() {
    selectedType   = '';
    selectedReason = '';
    isAnonymous    = false;
    attachedImage  = null;
    detailsController.clear();
    charCount = 0;
    notifyListeners();
  }
}