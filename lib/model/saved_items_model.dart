class SavedItemsModel {
  final String id;
  final String title;
  final String itemImage;
  final String category;
  final String miles;
  final DateTime addedTime;

  const SavedItemsModel({
    required this.id,
    required this.title,
    required this.itemImage,
    required this.category,
    required this.miles,
    required this.addedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'itemImage': this.itemImage,
      'category': this.category,
      'miles': this.miles,
      'addedTime': this.addedTime,
    };
  }

  factory SavedItemsModel.fromMap(Map<String, dynamic> map) {
    return SavedItemsModel(
      id: map['id'] as String,
      title: map['title'] as String,
      itemImage: map['itemImage'] as String,
      category: map['category'] as String,
      miles: map['miles'] as String,
      addedTime: map['addedTime'] as DateTime,
    );
  }
}