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

    await _firestore.collection('requests').add({
      'donorId': currentUser.uid,
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
}