import 'package:cloud_firestore/cloud_firestore.dart';

class RequestSystemModel {
  final String id;
  final String itemName;
  final String donorId;
  final String donorName;
  final String donationId; // 👈 ADDED — links this request back to its donation
  final String category;
  final String location;
  final String note;
  final List<String> images;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final String userId;

  RequestSystemModel({
    required this.id,
    required this.itemName,
    required this.donorId,
    required this.donorName,
    required this.donationId, // 👈 ADDED
    required this.category,
    required this.location,
    required this.note,
    required this.images,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  factory RequestSystemModel.fromFirestore(
      Map<String, dynamic> data,
      String id, {
        String donorName = '',
      }) {
    return RequestSystemModel(
      id: id,
      itemName: data['itemName'] ?? '',
      donorId: data['donorId'] ?? '',
      donorName: donorName,
      donationId: data['donationId'] ?? '', // 👈 ADDED
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      note: data['note'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'donorId': donorId,
      'donationId': donationId, // 👈 ADDED
      'category': category,
      'location': location,
      'note': note,
      'images': images,
      'tags': tags,
      'status': status,
      'createdAt': createdAt,
    };
  }

  RequestSystemModel copyWith({String? status}) {
    return RequestSystemModel(
      id: id,
      itemName: itemName,
      donorId: donorId,
      donorName: donorName,
      donationId: donationId, // 👈 ADDED
      category: category,
      location: location,
      note: note,
      images: images,
      tags: tags,
      status: status ?? this.status,
      createdAt: createdAt,
      userId: userId
    );
  }
}