import 'package:flutter/material.dart';

import '../model/review_model.dart';
import '../repo/review_repo.dart';

class ReviewViewModel extends ChangeNotifier {

  final ReviewRepository repository;

  ReviewViewModel({
    required this.repository,
  });

  List<ReviewModel> reviews = [];

  bool isLoading = false;

  Future<void> getAllReviews() async {

    isLoading = true;
    notifyListeners();

    reviews = await repository.getAllReviews();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addReview(ReviewModel review) async {
    await repository.addReview(review);
    await getAllReviews();
  }

  Future<void> deleteReview(String id) async {
    await repository.deleteReview(id);
    await getAllReviews();
  }

  Future<void> updateReview(ReviewModel review) async {
    await repository.updateReview(review);
    await getAllReviews();
  }

  double get averageRating {

    if (reviews.isEmpty) {
      return 0;
    }

    double total = reviews.fold(
      0,
          (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  List<ReviewModel> filterByRating(int rating) {

    if (rating == 0) {
      return reviews;
    }

    return reviews.where(
          (review) => review.rating == rating,
    ).toList();
  }
}