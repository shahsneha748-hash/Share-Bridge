import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerTaskModel {
  final String id;
  final String donationId;
  final String donationTitle;
  final String donationImage;
  final String donorId;
  final String receiverName;
  final String pickupLocation;
  final String deliveryLocation;
  final String status;
  final String? assignedVolunteerId;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  VolunteerTaskModel({
    required this.id,
    required this.donationId,
    required this.donationTitle,
    required this.donationImage,
    required this.donorId,
    required this.receiverName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.status,
    required this.assignedVolunteerId,
    this.acceptedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory VolunteerTaskModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return VolunteerTaskModel(
      id: documentId,
      donationId: map['donationId'] ?? '',
      donationTitle: map['donationTitle'] ?? '',
      donationImage: map['donationImage'] ?? '',
      donorId: map['donorId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      deliveryLocation: map['deliveryLocation'] ?? '',
      status: map['status'] ?? 'available',
      assignedVolunteerId: map['assignedVolunteerId'] ?? '',
      acceptedAt: map['acceptedAt'] != null
          ? (map['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donationTitle': donationTitle,
      'donationImage': donationImage,
      'donorId': donorId,
      'receiverName': receiverName,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'status': status,
      'assignedVolunteerId': assignedVolunteerId,
      'acceptedAt':
      acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt':
      completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  VolunteerTaskModel copyWith({
    String? id,
    String? donationId,
    String? donationTitle,
    String? donationImage,
    String? donorId,
    String? receiverName,
    String? pickupLocation,
    String? deliveryLocation,
    String? status,
    String? assignedVolunteerId,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return VolunteerTaskModel(
      id: id ?? this.id,
      donationId: donationId ?? this.donationId,
      donationTitle: donationTitle ?? this.donationTitle,
      donationImage: donationImage ?? this.donationImage,
      donorId: donorId ?? this.donorId,
      receiverName: receiverName ?? this.receiverName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      assignedVolunteerId:
      assignedVolunteerId ?? this.assignedVolunteerId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}