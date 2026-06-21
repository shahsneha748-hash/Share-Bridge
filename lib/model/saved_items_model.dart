class SavedItem {
  final String id;
  final String title;
  final String itemImage;

  const SavedItem({
    required this.id,
    required this.title,
    required this.itemImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'itemImage': this.itemImage,
    };
  }

  factory SavedItem.fromMap(Map<String, dynamic> map) {
    return SavedItem(
      id: map['id'] as String,
      title: map['title'] as String,
      itemImage: map['itemImage'] as String,
    );
  }
}