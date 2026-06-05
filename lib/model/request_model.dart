enum RequestStatus { pending, accepted, rejected }

class RequestModel {
  final String id;
  final String name;
  final String category;
  final String message;
  final String location;
  final String preferredPickup;
  RequestStatus status;
  String? scheduledTime;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.message,
    required this.location,
    required this.preferredPickup,
    this.status = RequestStatus.pending,
    this.scheduledTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'message': message,
    'location': location,
    'preferredPickup': preferredPickup,
    'status': status.name,
    'scheduledTime': scheduledTime,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RequestModel.fromMap(Map<String, dynamic> map) => RequestModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    message: map['message'] ?? '',
    location: map['location'] ?? '',
    preferredPickup: map['preferredPickup'] ?? '',
    status: RequestStatus.values.firstWhere(
            (e) => e.name == map['status'], orElse: () => RequestStatus.pending),
    scheduledTime: map['scheduledTime'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}