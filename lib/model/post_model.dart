class PostModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;

  const PostModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'ownerId': this.ownerId,
      'title': this.title,
      'description': this.description,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }
}
