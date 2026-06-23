import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String type;
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
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "type": type,
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
    };
  }

  /// Convert from Firestore map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map["id"] ?? "",
      senderId: map["senderId"] ?? "",
      receiverId: map["receiverId"] ?? "",
      type: map["type"] ?? "",
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
    );
  }

  /// Copy with new values
  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? type,
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
    String? imageUrl,
    String? filePath,
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
    );
  }
}


// Note: Model = raw data only (like a database row).