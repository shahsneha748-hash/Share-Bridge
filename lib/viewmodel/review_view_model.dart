import 'dart:async';
import 'package:flutter/material.dart';

import '../model/review_model.dart';
import '../repo/review_repo.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepo repository;

  ReviewViewModel({
    required this.repository,
  });

  List<ReviewModel> reviews = [];

  bool isLoading = false;

  StreamSubscription<List<ReviewModel>>? _subscription;

  void getReviewsForUser(String targetUserId) {
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = repository.getReviewsForUser(targetUserId).listen(
          (data) {
        reviews = data;
        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Error fetching reviews: $error");
        reviews = [];
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addReview(ReviewModel review) async {
    await repository.addReview(review);
  }

  Future<void> updateReview(ReviewModel review) async {
    await repository.updateReview(review);
  }

  Future<void> deleteReview(String reviewId) async {
    await repository.deleteReview(reviewId);
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;

    double total = reviews.fold(
      0,
          (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  List<ReviewModel> filterByRating(int rating) {
    if (rating == 0) return reviews;

    return reviews.where((review) {
      return review.rating.toInt() == rating;
    }).toList();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}