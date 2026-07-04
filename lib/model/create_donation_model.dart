class CreateDonationModel {

  String userId;
  String location;
  String itemName;
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

  List<String> tags;
  List<String> images;

  CreateDonationModel({

    this.userId = '',
    this.location = '',
    this.itemName = '',
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

    List<String>? tags,
    List<String>? images,
  })  : tags = tags ?? [],
        images = images ?? [];

  // ================= FROM MAP =================
  factory CreateDonationModel.fromMap(Map<String, dynamic> map) {
    return CreateDonationModel(

      userId: map['userId'] ?? '',
      location: map['location'] ?? '',
      itemName: map['itemName'] ?? '',
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

      tags: List<String>.from(map['tags'] ?? []),
      images: List<String>.from(map['images'] ?? []),
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'location': location,
      'itemName': itemName,
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

      'tags': tags,
      'images': images,
    };
  }
}