class CreateDonationModel {
  String userId;
  String donorId;
  String donorName;

  String location;
  double? mapLat;
  double? mapLng;

  String itemName;
  String title;
  String description;
  String expiryDate;
  String unit;
  String category;
  String subcategory;
  String condition;
  String note;
  String portion;
  String weight;

  int portionCount;
  bool isDonated;

  double donorRating;
  int donorDonations;

  List<String> tags;
  List<String> images;

  CreateDonationModel({
    this.userId = '',
    this.donorId = '',
    this.donorName = 'Unknown',

    this.location = '',
    this.mapLat,
    this.mapLng,

    this.itemName = '',
    this.title = '',
    this.description = '',
    this.expiryDate = '',
    this.unit = '',
    this.category = '',
    this.subcategory = '',
    this.condition = '',
    this.note = '',
    this.portion = '',
    this.weight = '',

    this.portionCount = 1,
    this.isDonated = false,

    this.donorRating = 0.0,
    this.donorDonations = 0,

    List<String>? tags,
    List<String>? images,
  })  : tags = tags ?? [],
        images = images ?? [];

  // ================= FROM MAP =================
  factory CreateDonationModel.fromMap(Map<String, dynamic> map) {
    return CreateDonationModel(
      userId: map['userId'] ?? '',
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? 'Unknown',

      location: map['location'] ?? '',
      mapLat: (map['mapLat'] as num?)?.toDouble(),
      mapLng: (map['mapLng'] as num?)?.toDouble(),

      itemName: map['itemName'] ?? '',
      title: map['title'] ?? map['itemName'] ?? '',
      description: map['description'] ?? '',
      expiryDate: map['expiryDate'] ?? '',
      unit: map['unit'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      condition: map['condition'] ?? '',
      note: map['note'] ?? '',
      portion: map['portion'] ?? '',
      weight: map['weight'] ?? '',

      portionCount: map['portionCount'] ?? 1,
      isDonated: map['isDonated'] ?? false,

      donorRating: (map['donorRating'] as num?)?.toDouble() ?? 0.0,
      donorDonations: map['donorDonations'] ?? 0,

      tags: List<String>.from(map['tags'] ?? []),
      images: List<String>.from(map['images'] ?? []),
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'donorId': donorId,
      'donorName': donorName,

      'location': location,
      'mapLat': mapLat,
      'mapLng': mapLng,

      'itemName': itemName,
      // title mirrors itemName unless explicitly set — keeps ItemDetailScreen's
      // item['title'] working without renaming everything.
      'title': title.isNotEmpty ? title : itemName,

      'description': description,
      'expiryDate': expiryDate,
      'unit': unit,
      'category': category,
      'subcategory': subcategory,
      'condition': condition,
      'note': note,
      'portion': portion,
      'weight': weight,

      'portionCount': portionCount,
      'isDonated': isDonated,

      'donorRating': donorRating,
      'donorDonations': donorDonations,

      'tags': tags,
      'images': images,
    };
  }
}