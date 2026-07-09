import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/admin_volunteer_model.dart';
import '../repo/admin_volunteer_repo.dart';
import '../repo/admin_volunteer_repo_impl.dart';

class AdminVolunteerViewModel extends ChangeNotifier {
  final AdminVolunteerRepo _repo = AdminVolunteerRepoImpl();

  List<AdminVolunteerModel> _volunteers = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  List<AdminVolunteerModel> get volunteers {
    if (_selectedFilter == 'All') return _volunteers;
    return _volunteers.where((v) => v.status == _selectedFilter).toList();
  }

  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  int get pendingCount =>
      _volunteers.where((v) => v.status == 'Pending').length;
  int get approvedCount =>
      _volunteers.where((v) => v.status == 'Approved').length;

  Future<void> loadVolunteers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _volunteers = await _repo.fetchVolunteers();
    } catch (e) {
      debugPrint('Error loading volunteers: $e');
      _volunteers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> updateStatus(String volunteerId, String status) async {
    try {
      await _repo.updateVolunteerStatus(volunteerId, status);

      // Send notification to the volunteer about the decision
      await _sendStatusNotification(volunteerId, status);

      await loadVolunteers();
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  /// Writes a notification to the volunteer using the app's
  /// notification structure (NotificationModel format).
  Future<void> _sendStatusNotification(
      String volunteerId, String status) async {
    // Only notify for decisions, not other status changes
    String body;
    String type;

    switch (status) {
      case 'Approved':
        body =
        'Congratulations! Your volunteer application has been approved. You can now start volunteering.';
        type = 'accepted';
        break;
      case 'Rejected':
        body =
        'Your volunteer application was not approved. Please review your details and re-apply.';
        type = 'rejected';
        break;
      case 'Suspended':
        body =
        'Your volunteer access has been suspended. Contact support for details.';
        type = 'rejected';
        break;
      default:
        return; // no notification for other statuses
    }

    try {
      final docRef =
      FirebaseFirestore.instance.collection('notifications').doc();

      await docRef.set({
        'id': docRef.id,
        'senderId': 'admin',
        'senderName': 'ShareBridge Team',
        'receiverId': volunteerId,
        'receiverName': '',
        'type': type,
        'body': body,
        'profilePicture': null,
        'targetId': volunteerId,
        'targetRole': 'volunteer',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'data': {},
        'pickupNumber': null,
        'assetImage': null,
        'filePath': null,
        'imageUrl': null,
        'postId': '',
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}