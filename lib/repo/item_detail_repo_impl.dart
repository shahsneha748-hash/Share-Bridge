import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/repo/item_detail_repo.dart';

class ItemDetailRepoImpl implements ItemDetailRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> toggleFollow(String donorName, bool currentlyFollowing) async {
    // TODO: connect to Firebase later — for now just flips locally
    await Future.delayed(const Duration(milliseconds: 150));
    return !currentlyFollowing;
  }

  @override
  Future<void> reportItem(String itemTitle) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> blockDonor(String donorName) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> sendRequest(Map<String, dynamic> item) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('You must be logged in to request an item.');
    }

    final donorId = item['donorId'] ?? '';
    final donorProfilePicture = await getDonorProfilePicture(donorId);

    // Fetch the requester's own profile so we can save their name/address/phone
    // onto the request — AssignVolunteerScreen and the tracking screens depend on these.
    String receiverName = currentUser.displayName ?? '';
    String receiverAddress = '';
    String receiverPhone = '';
    try {
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      if (userData != null) {
        receiverName = userData['fullName'] ?? userData['name'] ?? receiverName;
        receiverAddress = userData['address'] ?? '';
        receiverPhone = userData['phone'] ?? userData['phoneNumber'] ?? '';
      }
    } catch (_) {
      // fall back to whatever defaults we already have
    }

    await _firestore.collection('requests').add({
      'donorId': donorId,
      'donorName': item['donorName'] ?? '',
      'donorProfilePicture': donorProfilePicture ?? '',
      'userId': currentUser.uid,
      'receiverId': currentUser.uid,   // 👈 ADDED — this is the field everything downstream reads
      'receiverName': receiverName,    // 👈 ADDED
      'receiverAddress': receiverAddress, // 👈 ADDED
      'receiverPhone': receiverPhone,  // 👈 ADDED
      'donationId': item['id'] ?? '',
      'itemName': item['itemName'] ?? item['title'] ?? '',
      'category': item['category'] ?? '',
      'location': item['location'] ?? '',
      'note': '',
      'images': item['images'] ?? [],
      'tags': item['tags'] ?? [],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String?> getDonorProfilePicture(String donorId) async {
    if (donorId.isEmpty) return null;
    try {
      final doc = await _firestore.collection('users').doc(donorId).get();
      final data = doc.data();
      if (data == null) return null;
      return data['profilePicture'] as String?;
    } catch (e) {
      return null;
    }
  }
}