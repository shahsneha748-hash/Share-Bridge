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

        final rawCategory = data['category']?.toString() ?? '';
        final category = _mapCategory(rawCategory);

        final images = List<String>.from(data['images'] ?? []);

        final acceptedAt =
        (data['acceptedAt'] as Timestamp?)?.toDate();

        final status = data['status'] ?? 'available';
        final userId = data['userId'] ?? '';

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

          }
        }

        return {
          'id': doc.id,
          'title': data['itemName'] ?? '',
          'images': images,
          'image': images.isNotEmpty ? images[0] : null,
          'available': status == 'available',
          'isDonated': status == 'claimed',
          'status': status,
          'acceptedAt': acceptedAt,
          'category': category,
          'location': data['location'] ?? '',
          'shortLocation': _shortLocation(data['location'] ?? ''),
          'mapLat': data['mapLat'],
          'mapLng': data['mapLng'],
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

  String _shortLocation(String location) {
    if (location.isEmpty) return '';
    return location.split(',').first.trim();
  }
}