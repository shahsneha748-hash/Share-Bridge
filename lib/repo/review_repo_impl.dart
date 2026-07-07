import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/review_model.dart';
import 'review_repo.dart';

class ReviewRepoImpl implements ReviewRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 🔥 COLLECTION NAME
  final String collection = "reviews";

  @override
  Stream<List<ReviewModel>> getReviewsForUser(String targetUserId) {
    return firestore
        .collection(collection)
        .where("targetUserId", isEqualTo: targetUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromJson(doc.data());
      }).toList();
    });
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    await firestore
        .collection(collection)
        .doc(review.id)
        .set(review.toJson());
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    await firestore
        .collection(collection)
        .doc(review.id)
        .update(review.toJson());
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await firestore
        .collection(collection)
        .doc(reviewId)
        .delete();
  }
}