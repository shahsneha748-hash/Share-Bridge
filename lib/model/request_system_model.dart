class RequestSystemModel {
  String id;
  String name;
  String title;
  String description;
  String location;
  String category;
  bool isCompleted;

  RequestSystemModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'title': title,
    'description': description,
    'location': location,
    'category': category,
    'isCompleted': isCompleted,
  };

  factory RequestSystemModel.fromMap(Map<String, dynamic> map) {
    return RequestSystemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}