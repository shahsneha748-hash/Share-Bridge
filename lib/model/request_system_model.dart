import 'package:cloud_firestore/cloud_firestore.dart';

class DonationRequestModel {
  final String id;
  final String itemName;
  final String category;
  final String description;
  final String location;
  final String condition;
  final String weight;
  final String note;
  final List<String> images;
  final List<String> tags;
  final String status;
  final DateTime createdAt;

  DonationRequestModel({
    required this.id,
    required this.itemName,
    required this.category,
    required this.description,
    required this.location,
    required this.condition,
    required this.weight,
    required this.note,
    required this.images,
    required this.tags,
    required this.status,
    required this.createdAt,
  });

  factory DonationRequestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return DonationRequestModel(
      id: id,
      itemName: data['itemName'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      condition: data['condition'] ?? '',
      weight: data['weight'] ?? '',
      note: data['note'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'category': category,
      'description': description,
      'location': location,
      'condition': condition,
      'weight': weight,
      'note': note,
      'images': images,
      'tags': tags,
      'status': status,
      'createdAt': createdAt,
    };
  }

  DonationRequestModel copyWith({String? status}) {
    return DonationRequestModel(
      id: id,
      itemName: itemName,
      category: category,
      description: description,
      location: location,
      condition: condition,
      weight: weight,
      note: note,
      images: images,
      tags: tags,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}