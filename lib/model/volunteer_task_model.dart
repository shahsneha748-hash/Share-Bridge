import 'package:cloud_firestore/cloud_firestore.dart';


class VolunteerTaskModel {
  final String taskId;
  final String requestId;
  final String donorId;
  final String receiverId;
  final String volunteerId;
  final String itemId;
  final String status;
  // Pending / Accepted / Rejected / InProgress / Reached / Completed
  final Map<String, dynamic>? pickupLocation;
  final Map<String, dynamic>? dropLocation;
  final Map<String, dynamic>? currentLocation;
  final DateTime? createdAt;
  final DateTime? respondedAt;
  final String itemName;
  final String itemImage;
  final String receiverName;



  const VolunteerTaskModel({
    required this.taskId,
    required this.requestId,
    required this.donorId,
    required this.receiverId,
    required this.volunteerId,
    required this.itemId,
    required this.status,
    this.pickupLocation,
    this.dropLocation,
    this.currentLocation,
    this.createdAt,
    this.respondedAt,
    this.itemName = '',
    this.itemImage = '',
    this.receiverName = '',
  });


  String get pickupAddress {
    return pickupLocation?['address']
        ?? 'Unknown pickup';
  }

  String get dropAddress {
    return dropLocation?['address']
        ?? 'Unknown drop';
  }


  factory VolunteerTaskModel.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return VolunteerTaskModel(
      taskId: id,
      requestId: map['requestId'] ?? '',
      donorId: map['donorId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      itemId: map['itemId'] ?? '',
      status: map['status'] ?? 'Pending',
      pickupLocation: _asLocationMap(map['pickupLocation']),
      dropLocation: _asLocationMap(map['deliveryLocation'] ?? map['dropLocation']),
      currentLocation: map['currentLocation'] as Map<String, dynamic>?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      itemName: map['itemName'] ?? '',
      itemImage: map['itemImage'] ?? '',
      receiverName: map['receiverName'] ?? '',
    );
  }


  static Map<String, dynamic>? _asLocationMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) return {'address': value};
    return null;
  }



  Map<String,dynamic> toMap(){
    return {
      "requestId": requestId,
      "donorId": donorId,
      "receiverId": receiverId,
      "volunteerId": volunteerId,
      "itemId": itemId,
      "status": status,
      "pickupLocation": pickupLocation,
      "dropLocation": dropLocation,
      "currentLocation": currentLocation,
      "createdAt": createdAt,
      "respondedAt": respondedAt,
      "itemName": itemName,
      "itemImage": itemImage,
      "receiverName": receiverName,
    };

  }

}