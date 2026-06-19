class ReviewModel {
  final String id;
  final String donationId;
  final String userId;
  final String name;
  final String initials;
  final double rating;
  final String review;
  final String time;
  final String date;
  final int likes;
  final bool liked;

  ReviewModel({
    required this.id,
    required this.donationId,
    required this.userId,
    required this.name,
    required this.initials,
    required this.rating,
    required this.review,
    required this.time,
    required this.date,
    required this.likes,
    required this.liked,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      donationId: json['donationId'],
      userId: json['userId'],
      name: json['name'],
      initials: json['initials'],
      rating: json['rating'].toDouble(),
      review: json['review'],
      time: json['time'],
      date: json['date'],
      likes: json['likes'],
      liked: json['liked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'userId': userId,
      'name': name,
      'initials': initials,
      'rating': rating,
      'review': review,
      'time': time,
      'date': date,
      'likes': likes,
      'liked': liked,
    };
  }
}