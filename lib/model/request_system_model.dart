import 'package:cloud_firestore/cloud_firestore.dart';

class RequestSystemModel {
  final String id;
  final String itemName;
  final String donorId;
  final String donorName;
  final String donationId;
  final String category;
  final String location;
  final String note;
  final List<String> images;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final String userId;
  final String? donorProfilePicture;
  final String userName;
  final String? userProfilePicture;
  final String receiverId;
  final String receiverName;
  final String receiverAddress;


  final String weight;
  final String portion;
  final int portionCount;
  final String receiverPhone;

  RequestSystemModel({
    required this.id,
    required this.itemName,
    required this.donorId,
    required this.donorName,
    required this.donationId,
    required this.category,
    required this.location,
    required this.note,
    required this.images,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.donorProfilePicture,
    required this.userName,
    this.userProfilePicture,
    this.receiverId = '',
    this.receiverName = '',
    this.receiverAddress = '',



    this.weight = '',
    this.portion = '',
    this.portionCount = 1,
    this.receiverPhone = '',

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
      donationId: data['donationId'] ?? '',
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
      donorProfilePicture: data['donorProfilePicture'],
      userName: data['userName'] ?? 'Unknown',
      userProfilePicture: data['userProfilePicture'],
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      receiverAddress: data['receiverAddress'] ?? '',

      weight: data['weight'] ?? '',
      portion: data['portion'] ?? '',
      portionCount: data['portionCount'] ?? 1,
      receiverPhone: data['receiverPhone'] ?? '',
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'donorId': donorId,
      'donationId': donationId,
      'category': category,
      'location': location,
      'note': note,
      'images': images,
      'tags': tags,
      'status': status,
      'createdAt': createdAt,
      'donorProfilePicture': donorProfilePicture,
      'userName': userName,
      'userProfilePicture': userProfilePicture,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAddress': receiverAddress,

      'weight': weight,
      'portion': portion,
      'portionCount': portionCount,
      'receiverPhone': receiverPhone,

    };
  }

  RequestSystemModel copyWith({String? status}) {
    return RequestSystemModel(
      id: id,
      itemName: itemName,
      donorId: donorId,
      donorName: donorName,
      donationId: donationId,
      category: category,
      location: location,
      note: note,
      images: images,
      tags: tags,
      status: status ?? this.status,
      createdAt: createdAt,
      userId: userId,
      donorProfilePicture: donorProfilePicture,
      userName: userName,
      userProfilePicture: userProfilePicture,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverAddress: receiverAddress,

      weight: weight,
      portion: portion,
      portionCount: portionCount,
      receiverPhone: receiverPhone,

    );
  }
}