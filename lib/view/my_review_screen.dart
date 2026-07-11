import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/constants/colors.dart';
import 'package:sharebridge/components/app_header.dart';
import 'package:sharebridge/model/review_model.dart';
import 'package:sharebridge/viewmodel/review_view_model.dart';

class MyReviewsScreen extends StatefulWidget {
  final String uid;
  const MyReviewsScreen({super.key, required this.uid});
  @override
  State<MyReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<MyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().getReviewsForUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: AppColors.darkGreen, // 👈 matches dashboard
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.cream),
                ),
                const Expanded(child: AppHeader(title: 'Reviews')),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.white, // 👈 white content area, same as dashboard
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
                    : vm.reviews.isEmpty
                    ? const Center(
                  child: Text('No reviews yet.', style: TextStyle(color: AppColors.textMuted)),
                )
                    : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryCard(vm),
                    const SizedBox(height: 16),
                    ...vm.reviews.map(_buildReviewCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryCard(ReviewViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                vm.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < vm.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: AppColors.ratingStar,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${vm.reviews.length} reviews",
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(vm, 5, Colors.green),
                _buildRatingBar(vm, 4, Colors.lightGreen),
                _buildRatingBar(vm, 3, Colors.orange),
                _buildRatingBar(vm, 2, Colors.deepOrange),
                _buildRatingBar(vm, 1, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
      ReviewViewModel vm,
      int star,
      Color color,
      ) {
    final total = vm.reviews.length;
    final count =
        vm.reviews.where((r) => r.rating.round() == star).length;
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              "$star",
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: AppColors.backgroundGreen,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              "$count",
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.darkGreen.withOpacity(0.15),
                child: Text(
                  review.reviewerInitials.isNotEmpty ? review.reviewerInitials : '?',
                  style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.reviewerName.isNotEmpty
                      ? review.reviewerName
                      : "User",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText),
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating.round() ? Icons.star : Icons.star_border,
                  size: 13,
                  color: AppColors.ratingStar,
                )),
              ),
            ],
          ),
          if (review.review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.review, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Spacer(),
              Icon(
                review.liked ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: review.liked ? Colors.red : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text('${review.likes}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}