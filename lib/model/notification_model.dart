import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id; // Firestore document ID
  final String userId; // Which user this notification belongs to
  final String type; // e.g. request, acceptance, rejection, reminder, expiry
  final String title; // Notification title (for push)
  final String body; // Notification body (for push)
  final String message; // Text shown in app notification list
  final DateTime timestamp; // When created
  final String? relatedUserId; // Optional link to which user send that notification etc.
  final String? image; // Optional image URL
  final Map<String, dynamic>? data;  // Extra payload for push notifications

  NotificationModel({           // This is named argument constructor. It's purpose is to initialize the object. (We made this For Readability: You can see which value is being passed to which field: Eg: UserModel(id: "123", name: "Cheten");)
    this.id,
    required this.userId,
    required this.type,         // With required written in front, you enforce that the caller must provide those values. No accidental nulls. Eg: NotificationModel(type: "reminder"); (required tells us we need this values from user compulsory!)
    required this.title,
    required this.body,
    required this.message,
    required this.timestamp,
    this.relatedUserId,
    this.image,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'userId': this.userId,
      'type': this.type,
      'title': this.title,
      'body': this.body,
      'message': this.message,
      'timestamp': this.timestamp,
      'relatedUserId': this.relatedUserId,
      'image': this.image,
      'data': this.data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] as DateTime,
      relatedUserId: map['relatedUserId'] as String,
      image: map['image'] as String,
      data: map['data'] as Map<String, dynamic>,
    );
  }
}

// Note: Model = raw data only (like a database row).