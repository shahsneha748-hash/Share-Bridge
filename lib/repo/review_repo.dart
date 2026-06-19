import '../model/review_model.dart';

abstract class ReviewRepository {

  Future<List<ReviewModel>> getAllReviews();

  Future<void> addReview(ReviewModel review);

  Future<void> deleteReview(String id);

  Future<void> updateReview(ReviewModel review);
}