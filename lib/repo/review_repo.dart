import '../model/review_model.dart';

abstract class ReviewRepo {

  // Get all reviews for a specific user (donor/volunteer)
  Stream<List<ReviewModel>> getReviewsForUser(String targetUserId);

  // Add new review
  Future<void> addReview(ReviewModel review);

  // Update review (likes, edits, etc.)
  Future<void> updateReview(ReviewModel review);

  // Delete review
  Future<void> deleteReview(String reviewId);
}