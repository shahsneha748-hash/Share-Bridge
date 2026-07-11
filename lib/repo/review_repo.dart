import '../model/review_model.dart';

abstract class ReviewRepo {

  Stream<List<ReviewModel>> getReviewsForUser(String targetUserId);


  Future<void> addReview(ReviewModel review);

  Future<void> updateReview(ReviewModel review);

  Future<void> deleteReview(String reviewId);
}