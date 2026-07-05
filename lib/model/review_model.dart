class ReviewModel {
  final String id;

  final String donationId;
  final String targetUserId; // donor or volunteer
  final String reviewType;
  final String reviewerId;
  final String reviewerName;
  final String reviewerInitials;

  final double rating;
  final String review;

  final DateTime createdAt;

  final int likes;
  final bool liked;

  ReviewModel({
    required this.id,
    required this.donationId,
    required this.targetUserId,
    required this.reviewType,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerInitials,

    required this.rating,
    required this.review,

    required this.createdAt,

    required this.likes,
    required this.liked,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      donationId: json['donationId'],
      targetUserId: json['targetUserId'],
      reviewType: json['reviewType'],

      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
      reviewerInitials: json['reviewerInitials'],

      rating: (json['rating'] as num).toDouble(),
      review: json['review'],

      createdAt: DateTime.parse(json['createdAt']),

      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'targetUserId': targetUserId,
      'reviewType': reviewType,

      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerInitials': reviewerInitials,

      'rating': rating,
      'review': review,

      'createdAt': createdAt.toIso8601String(),

      'likes': likes,
      'liked': liked,
    };
  }
}