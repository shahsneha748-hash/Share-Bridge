import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {              // NotificationModel is the data structure (model) that holds all the information your UI needs to display notifications.
  final String id;
  final String userId;
  final String type;        // e.g. of type is: request, acceptance, rejection, reminder, expiry
  final String message;     // text shown in notification
  final DateTime timestamp; // when created
  final bool isRead;        // true if user opened it
  final String? relatedItemId; // optional link to donation post
  final String? image;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.relatedItemId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'type': this.type,
      'message': this.message,
      'timestamp': this.timestamp,
      'isRead': this.isRead,
      'relatedItemId': this.relatedItemId,
      'image': this.image,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: map['type'] as String,
      message: map['message'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(), // Firestore stores DateTime as Timestamp
      isRead: map['isRead'] as bool,
      relatedItemId: map['relatedItemId'] as String?, // safe cast
      image: map['image'] as String?, // safe cast
    );
  }

}
