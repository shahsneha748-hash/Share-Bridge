import 'package:sharebridge/repo/review_repo.dart';

import '../model/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {

  final List<ReviewModel> _reviews = [];

  @override
  Future<List<ReviewModel>> getAllReviews() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _reviews;
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    _reviews.add(review);
  }

  @override
  Future<void> deleteReview(String id) async {
    _reviews.removeWhere((review) => review.id == id);
  }

  @override
  Future<void> updateReview(ReviewModel review) async {

    final index =
    _reviews.indexWhere((element) => element.id == review.id);

    if (index != -1) {
      _reviews[index] = review;
    }
  }
}