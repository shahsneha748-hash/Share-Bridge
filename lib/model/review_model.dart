class ReviewModel {
  final String id;

  // Who is being reviewed
  final String targetUserId;
  final String reviewType; // donor / volunteer

  // Who wrote the review
  final String reviewerId;
  final String reviewerName;
  final String reviewerInitials;

  // Donation connection
  final String donationId;

  // Review content
  final double rating;
  final String review;

  final DateTime createdAt;

  // Interaction
  final int likes;
  final bool liked;


  ReviewModel({
    required this.id,

    required this.targetUserId,
    required this.reviewType,

    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerInitials,

    required this.donationId,

    required this.rating,
    required this.review,

    required this.createdAt,

    required this.likes,
    required this.liked,
  });


  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',

      targetUserId: json['targetUserId'] ?? '',
      reviewType: json['reviewType'] ?? '',

      reviewerId: json['reviewerId'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewerInitials: json['reviewerInitials'] ?? '',

      donationId: json['donationId'] ?? '',

      rating: (json['rating'] ?? 0).toDouble(),
      review: json['review'] ?? '',

      createdAt: DateTime.parse(json['createdAt']),

      likes: json['likes'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }


  Map<String, dynamic> toJson() {
    return {

      'id': id,

      'targetUserId': targetUserId,
      'reviewType': reviewType,

      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerInitials': reviewerInitials,

      'donationId': donationId,

      'rating': rating,
      'review': review,

      'createdAt': createdAt.toIso8601String(),

      'likes': likes,
      'liked': liked,
    };
  }
}