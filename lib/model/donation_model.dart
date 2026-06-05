class DonationModel {
  final String id;
  final String firstName;
  final String lastName;
  final String location;
  final String itemName;
  final String condition;
  final String category;
  final String description;
  final List<String> photoUrls;
  final bool isDonated;
  final DateTime createdAt;
  final String? expiresAt;

  DonationModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.itemName,
    required this.condition,
    required this.category,
    required this.description,
    this.photoUrls = const [],
    this.isDonated = false,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'location': location,
    'itemName': itemName,
    'condition': condition,
    'category': category,
    'description': description,
    'photoUrls': photoUrls,
    'isDonated': isDonated,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt,
  };

  factory DonationModel.fromMap(Map<String, dynamic> map) => DonationModel(
    id: map['id'] ?? '',
    firstName: map['firstName'] ?? '',
    lastName: map['lastName'] ?? '',
    location: map['location'] ?? '',
    itemName: map['itemName'] ?? '',
    condition: map['condition'] ?? '',
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    photoUrls: List<String>.from(map['photoUrls'] ?? []),
    isDonated: map['isDonated'] ?? false,
    createdAt: DateTime.parse(map['createdAt']),
    expiresAt: map['expiresAt'],
  );
}