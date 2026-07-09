import 'package:cloud_firestore/cloud_firestore.dart';

/// Checks the current user's donations for upcoming expiry dates
/// and creates alert notifications (runs when notifications load).
/// Uses deterministic doc IDs so the same alert is never duplicated.
class ExpiryAlertService {
  static Future<void> checkAndCreateAlerts(String uid) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Get this user's active donations
      final snapshot = await firestore
          .collection('donations')
          .where('donorId', isEqualTo: uid)
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Skip taken/donated items
        if (data['isDonated'] == true) continue;

        // Only items with an expiry date
        final expiryRaw = data['expiryDate'];
        if (expiryRaw == null || expiryRaw.toString().isEmpty) continue;

        DateTime expiry;
        try {
          expiry = DateTime.parse(expiryRaw.toString());
        } catch (_) {
          continue; // unparseable date — skip
        }
        final expiryDay =
        DateTime(expiry.year, expiry.month, expiry.day);

        final daysLeft = expiryDay.difference(today).inDays;
        final title = data['title'] ?? data['itemName'] ?? 'Your item';

        String? body;
        String? type;

        if (daysLeft == 0) {
          body = '⚠️ "$title" is expiring TODAY! Consider prioritizing its pickup.';
          type = 'alert';
        } else if (daysLeft == 1) {
          body = '⚠️ "$title" expires tomorrow. Plan its pickup soon.';
          type = 'alert';
        } else if (daysLeft == 2) {
          body = '⚠️ "$title" expires in 2 days.';
          type = 'normal_alert';
        } else if (daysLeft == 3) {
          body = '⚠️ "$title" expires in 3 days.';
          type = 'normal_alert';
        } else if (daysLeft == 4) {
          body = '⚠️ "$title" expires in 4 days.';
          type = 'normal_alert';
        } else if (daysLeft == 5) {
          body = '⚠️ "$title" expires in 5 days. Plan ahead.';
          type = 'normal_alert';
        }

        if (body == null || type == null) continue;

        // Deterministic ID: one alert per donation per day — no duplicates
        final dateKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final notifId = 'expiry_${doc.id}_$dateKey';

        final notifRef =
        firestore.collection('notifications').doc(notifId);

        // Only create if it doesn't already exist
        final existing = await notifRef.get();
        if (existing.exists) continue;

        await notifRef.set({
          'id': notifId,
          'senderId': 'system',
          'senderName': 'ShareBridge',
          'receiverId': uid,
          'receiverName': '',
          'type': type,
          'body': body,
          'profilePicture': null,
          'targetId': doc.id,
          'targetRole': 'donor',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'data': {},
          'pickupNumber': null,
          'assetImage': null,
          'filePath': null,
          'imageUrl': null,
          'postId': doc.id,
        });
      }
    } catch (e) {
      // Silent fail — alerts are non-critical
      // ignore: avoid_print
      print('Expiry alert check failed: $e');
    }
  }
}