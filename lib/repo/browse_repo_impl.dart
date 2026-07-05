import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';

class BrowseRepoImpl implements BrowseRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<BrowseModel> getBrowseData() {
    return _firestore
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final items = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();

        // ── Map Firestore fields to browse item fields ──────────
        final rawCategory = data['category']?.toString() ?? '';
        final category = _mapCategory(rawCategory);

        final images = List<String>.from(data['images'] ?? []);

        final acceptedAt =
        (data['acceptedAt'] as Timestamp?)?.toDate();

        final status = data['status'] ?? 'pending';
        final userId = data['userId'] ?? '';

        // ── Look up donor info from users collection (keyed by uid) ──
        String donorName = 'Unknown';
        double donorRating = 0.0;
        int donorDonations = 0;

        if (userId.toString().isNotEmpty) {
          try {
            final userDoc =
            await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              donorName = userData?['fullName'] ?? 'Unknown';
              donorRating = (userData?['rating'] is num)
                  ? (userData!['rating'] as num).toDouble()
                  : 0.0;
              donorDonations = (userData?['totalDonations'] is int)
                  ? userData!['totalDonations']
                  : 0;
            }
          } catch (e) {
            // keep defaults if lookup fails
          }
        }

        return {
          'id': doc.id,
          'title': data['itemName'] ?? '',
          'images': images,
          'image': images.isNotEmpty ? images[0] : null,
          'available': status == 'pending',
          // isDonated drives the Available/Taken badge on Item Detail
          'isDonated': status == 'accepted',
          'status': status,
          'acceptedAt': acceptedAt,
          'category': category,
          'location': data['location'] ?? '',
          'shortLocation': _shortLocation(data['location'] ?? ''),
          'description': data['description'] ?? '',
          'condition': data['condition'] ?? '',
          'weight': data['weight'] ?? '',
          'note': data['note'] ?? '',
          'tags': List<String>.from(data['tags'] ?? []),
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'userId': userId,
          'donorId': userId,
          'donorName': donorName,
          'donorRating': donorRating,
          'donorDonations': donorDonations,
          'portion': data['portionCount'] != null
              ? '${data['portionCount']} people'
              : '',
        };
      }));

      return BrowseModel(allItems: items);
    });
  }

  // Maps Firestore lowercase category to UI display category
  String _mapCategory(String raw) {
    switch (raw.toLowerCase()) {
      case 'food':
        return 'Food';
      case 'clothes':
        return 'Clothes';
      case 'stationery':
        return 'Stationery';
      default:
        return 'Others';
    }
  }

  // Shortens location to first part before comma
  String _shortLocation(String location) {
    if (location.isEmpty) return '';
    return location.split(',').first.trim();
  }
}