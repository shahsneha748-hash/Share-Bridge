class PickupNotificationModel {
  final String? id;
  final String title;
  final String description;
  final String targetRole;
  final String? senderId;
  final String? receiverId;
  final String? senderName;
  final String? receiverName;
  final String? profilePicture;
  final DateTime createdAt;
  final bool isRead;


  PickupNotificationModel({
    this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    this.senderId,
    this.receiverId,
    this.senderName,
    this.receiverName,
    this.profilePicture,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
      'targetRole': this.targetRole,
      'senderId': this.senderId,
      'receiverId': this.receiverId,
      'senderName': this.senderName,
      'receiverName': this.receiverName,
      'profilePicture': this.profilePicture,
      'createdAt': this.createdAt,
      'isRead': this.isRead,
    };
  }

  factory PickupNotificationModel.fromMap(Map<String, dynamic> map) {
    return PickupNotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      targetRole: map['targetRole'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      senderName: map['senderName'] as String,
      receiverName: map['receiverName'] as String,
      profilePicture: map['profilePicture'] as String,
      createdAt: map['createdAt'] as DateTime,
      isRead: map['isRead'] as bool,
    );
  }
}