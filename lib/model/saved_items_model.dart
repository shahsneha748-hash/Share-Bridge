import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItemsModel {
  final String id;
  final String title;
  final List<String> images; // 👈 Cloudinary list
  final String category;
  final String miles;
  final String addedTime;
  final String image;

  SavedItemsModel({
    required this.id,
    required this.title,
    required this.images,
    required this.category,
    required this.miles,
    required this.addedTime,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "category": category,
      "images": images,   // 👈 save the full list
      "image": images.isNotEmpty ? images[0] : "",
      "miles": miles,
      "addedTime": addedTime,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  factory SavedItemsModel.fromMap(Map<String, dynamic> map) {
    return SavedItemsModel(
      id: map["id"] ?? "",
      title: map["title"] ?? "",
      images: List<String>.from(map["images"] ?? []),
      category: map["category"] ?? "Others",
      miles: map["miles"] ?? "",
      addedTime: map["addedTime"] ?? "",
      image: map["image"] ?? "",
    );
  }
}
