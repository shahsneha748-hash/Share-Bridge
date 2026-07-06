import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_donation_model.dart';

class DonationRecord {
  final String id;
  final DateTime? createdAt;
  final String status;
  final CreateDonationModel model;

  const DonationRecord({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.model,
  });

  factory DonationRecord.fromFirestore(String id, Map<String, dynamic> map) {
    DateTime? parsedDate;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is Timestamp) {
      parsedDate = createdAtRaw.toDate();
    }

    return DonationRecord(
      id: id,
      createdAt: parsedDate,
      status: map['status'] as String? ?? 'pending',
      model: CreateDonationModel.fromMap(map),
    );
  }
}