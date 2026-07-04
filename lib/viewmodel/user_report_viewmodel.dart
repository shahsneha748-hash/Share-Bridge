import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_report_model.dart';
import '../model/user_model.dart';
import '../repo/user_report_repo.dart';
import '../repo/user_report_repo_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserReportViewModel extends ChangeNotifier {
  final UserReportRepo _repo = UserReportRepoImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedType = '';
  String selectedReason = '';
  bool isAnonymous = false;
  bool isSubmitting = false;
  bool isLoadingItems = false;
  File? attachedImage;

  // Selected items
  UserModel? selectedUser;
  // Add selectedDonation and selectedVolunteer later when teammates push code

  // Lists from Firestore
  List<UserModel> usersList = [];

  final TextEditingController detailsController = TextEditingController();
  int charCount = 0;

  UserReportViewModel() {
    detailsController.addListener(() {
      charCount = detailsController.text.length;
      notifyListeners();
    });
  }

  bool get canSubmit =>
      selectedType.isNotEmpty &&
          selectedReason.isNotEmpty &&
          charCount >= 15 &&
          _hasSelectedItem();

  bool _hasSelectedItem() {
    if (selectedType == 'A User') return selectedUser != null;
    // Add donation and volunteer checks later
    return false;
  }

  // Reporting card display data
  String get reportingName {
    if (selectedType == 'A User' && selectedUser != null) {
      return selectedUser!.fullName;
    }
    return '';
  }

  String get reportingInitial {
    if (selectedType == 'A User' && selectedUser != null) {
      return selectedUser!.fullName.isNotEmpty
          ? selectedUser!.fullName[0].toUpperCase()
          : '?';
    }
    return '?';
  }

  String get reportingSubtitle {
    if (selectedType == 'A User' && selectedUser != null) {
      return '${selectedUser!.rating} · ${selectedUser!.role} · ${selectedUser!.email}';
    }
    return '';
  }

  int get reportingStars {
    if (selectedType == 'A User' && selectedUser != null) {
      return selectedUser!.rating.round();
    }
    return 0;
  }

  void selectType(String type) {
    selectedType = type;
    selectedUser = null; // reset selection
    notifyListeners();
    _fetchItemsForType(type);
  }

  Future<void> _fetchItemsForType(String type) async {
    if (type == 'A User') {
      await _fetchUsers();
    }
    // Add donations and volunteers fetch later
  }

  Future<void> _fetchUsers() async {
    isLoadingItems = true;
    notifyListeners();
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final snapshot = await _firestore
          .collection('users')
          .get();

      debugPrint('Total docs fetched: ${snapshot.docs.length}');

      usersList = snapshot.docs
          .map((doc) {
        final data = doc.data();
        data['profilePicture'] = data['profilePicture'] ?? '';
        data['phone'] = data['phone'] ?? '';
        data['address'] = data['address'] ?? '';
        data['createdAt'] = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        data['updatedAt'] = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        data['rating'] = data['rating'] ?? 0.0;
        data['totalDonations'] = data['totalDonations'] ?? 0;
        data['isVerified'] = data['isVerified'] ?? false;
        return UserModel.fromMap(data);
      })
          .where((u) {
        debugPrint('User id: ${u.uid}, currentUid: $currentUid');
        return u.uid != currentUid;
      })
          .toList();

      debugPrint('Final users list: ${usersList.length}');

      debugPrint('Users list length: ${usersList.length}');
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
    isLoadingItems = false;
    notifyListeners();
  }
  void selectUser(UserModel user) {
    selectedUser = user;
    notifyListeners();
  }

  void selectReason(String reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void toggleAnonymous(bool val) {
    isAnonymous = val;
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Attach Evidence",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3DE),
                child: Icon(Icons.photo_library, color: Color(0xFF4A7C26)),
              ),
              title: const Text("Choose from Gallery"),
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
              title: const Text("Take a Photo"),
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

  Future<void> submitReport(BuildContext context) async {
    if (!canSubmit) return;
    isSubmitting = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

// Fetch current user's name from Firestore
      String reporterName = 'Anonymous';
      if (!isAnonymous) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        reporterName = userDoc.data()?['fullName'] as String? ?? 'Unknown';
      }

      await _repo.submitReport({
        'reporterId': isAnonymous ? 'anonymous' : uid,
        'reporterName': reporterName,
        'reportedId': selectedUser?.uid ?? '',
        'reportedName': selectedUser?.fullName ?? '',
        'reportType': selectedType,
        'reason': selectedReason,
        'details': detailsController.text.trim(),
        'isAnonymous': isAnonymous,
        'status': 'pending',
        'createdAt': DateTime.now(),
      });

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF4A7C26), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Report Submitted!',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for keeping ShareBridge safe. Our team will review your report.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5A14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Done',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit report. Try again.')),
        );
      }
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void removeImage() {
    attachedImage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }
}