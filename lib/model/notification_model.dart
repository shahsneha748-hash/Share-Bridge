import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { request, pickup, alert, normal_alert, accepted, rejected }

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final NotificationType type;
  final String title;
  final String body;
  final String? profilePicture;
  final String? targetId;
  final String? targetRole;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? pickupNumber;
  final String? assetImage;
  final String? filePath;
  final String? imageUrl;
  final String? senderName;
  final String? receiverName;


  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.title,
    required this.body,
    this.profilePicture,
    this.targetId,
    this.targetRole,
    required this.createdAt,
    required this.isRead,
    this.data,
    this.pickupNumber,
    this.assetImage,
    this.filePath,
    this.imageUrl,
    this.senderName,
    this.receiverName,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "type": type.toString().split('.').last,
      "title": title,
      "body": body,
      "profilePicture": profilePicture,
      "targetId": targetId,
      "targetRole": targetRole,
      "createdAt": createdAt,
      "isRead": isRead,
      "data": data ?? {},
      "pickupNumber": pickupNumber,
      "assetImage": assetImage,
      "filePath": filePath,
      "imageUrl": imageUrl,
      "senderName": senderName,
      "receiverName": receiverName,
    };
  }

  /// Convert from Firestore map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map["id"] ?? "",
      senderId: map["senderId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      type: _mapStringToType(map["type"]),   // ✅ convert string back to enum
      title: map["title"] ?? "",
      body: map["body"] ?? "",
      profilePicture: map["profilePicture"],
      targetId: map["targetId"],
      targetRole: map["targetRole"],
      createdAt: (map["createdAt"] is Timestamp)
          ? (map["createdAt"] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map["isRead"] ?? false,
      data: map["data"],
      pickupNumber: map["pickupNumber"],
      assetImage: map["assetImage"],
      filePath: map["filePath"],
      imageUrl: map["imageUrl"],
      senderName: map["senderName"],
      receiverName: map["receiverName"],
    );
  }

  /// Helper to map Firestore string to enum
  static NotificationType _mapStringToType(String? type) {
    switch (type) {
      case 'request': return NotificationType.request;
      case 'pickup': return NotificationType.pickup;
      case 'alert': return NotificationType.alert;
      case 'normal_alert': return NotificationType.normal_alert;
      case 'accepted': return NotificationType.accepted;
      case 'rejected': return NotificationType.rejected;
      default: return NotificationType.alert;
    }
  }

  /// Copy with new values
  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    NotificationType? type,   // ✅ enum instead of String
    String? title,
    String? body,
    String? profilePicture,
    String? targetId,
    String? targetRole,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? pickupNumber,
    String? assetImage,
    String? filePath,
    String? imageUrl,
    String? senderName,
    String? receiverName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      profilePicture: profilePicture ?? this.profilePicture,
      targetId: targetId ?? this.targetId,
      targetRole: targetRole ?? this.targetRole,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      pickupNumber: pickupNumber ?? this.pickupNumber,
      assetImage: assetImage ?? this.assetImage,
      filePath: filePath ?? this.filePath,
      imageUrl: imageUrl ?? this.imageUrl,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,

    );
  }
}



// Note: Model = raw data only (like a database row).