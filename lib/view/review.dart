import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/review_model.dart';
import '../viewmodel/review_view_model.dart';

class RatingsReviewsPage extends StatefulWidget {
  const RatingsReviewsPage({super.key});

  @override
  State<RatingsReviewsPage> createState() => _RatingsReviewsPageState();
}

class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  int selectedFilter = 0;
  int selectedRating = 0;

  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ReviewViewModel>().getAllReviews();
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  // ✅ Fixed: takes vm as parameter
  void submitReview(ReviewViewModel vm) async {
    if (selectedRating == 0 || reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add rating and review")),
      );
      return;
    }

    final model = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donationId: "donationId_here",
      userId: "userId_here",
      name: "You",
      initials: "YU",
      rating: selectedRating.toDouble(),
      review: reviewController.text,
      time: "Just now",
      date: "Today",
      likes: 0,
      liked: false,
    );

    await vm.addReview(model);

    if (!mounted) return;

    setState(() {
      selectedRating = 0;
      reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    final filteredReviews = selectedFilter == 0
        ? vm.reviews
        : vm.reviews
        .where((r) => r.rating.toInt() == selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xfff1f4ee),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Ratings & Reviews",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ITEM CARD ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1200",
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Oversized Cotton T-Shirt",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Clothing",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Available",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ── RATING SUMMARY ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffE6D5B8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: index < vm.averageRating.round()
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${vm.reviews.length} reviews",
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 25),
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
            ),

            const SizedBox(height: 20),

            // ── FILTER CHIPS ───────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip("All", 0),
                  filterChip("+5", 5),
                  filterChip("+4", 4),
                  filterChip("+3", 3),
                  filterChip("+2", 2),
                  filterChip("+1", 1),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "User Reviews",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "${filteredReviews.length}",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 15),

            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              // ✅ Fixed: passes both review and vm
              children: filteredReviews
                  .map((review) => reviewCard(review, vm))
                  .toList(),
            ),

            const SizedBox(height: 25),

            // ── WRITE REVIEW ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Write a Review",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Share your experience with this donor",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedRating = index + 1),
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.star,
                            size: 34,
                            color: index < selectedRating
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your experience with this donor...",
                      filled: true,
                      fillColor: const Color(0xfff3f5f2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => submitReview(vm), // ✅ correct call
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dynamic bar from real data
  Widget _buildRatingBar(ReviewViewModel vm, int star, Color color) {
    final total = vm.reviews.length;
    final count = vm.reviews.where((r) => r.rating.toInt() == star).length;
    final ratio = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$star", style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text("$count", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget filterChip(String text, int value) {
    final selected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Fixed: ReviewModel + vm, no Map<String, dynamic>
  Widget reviewCard(ReviewModel review, ReviewViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  review.initials,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                    Text(review.time,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    Text(review.date,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "+${review.rating.toInt()}",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star,
                size: 16,
                color: index < review.rating
                    ? Colors.orange
                    : Colors.grey.shade300,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff4f6f3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(review.review,
                style: const TextStyle(height: 1.5)),
          ),

          const SizedBox(height: 12),

          // ✅ Like toggle via vm.updateReview
          GestureDetector(
            onTap: () {
              vm.updateReview(
                ReviewModel(
                  id: review.id,
                  donationId: review.donationId,
                  userId: review.userId,
                  name: review.name,
                  initials: review.initials,
                  rating: review.rating,
                  review: review.review,
                  time: review.time,
                  date: review.date,
                  likes: review.liked
                      ? review.likes - 1
                      : review.likes + 1,
                  liked: !review.liked,
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  review.liked ? Icons.favorite : Icons.favorite_border,
                  color: review.liked ? Colors.red : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  "${review.likes} people found this helpful",
                  style: TextStyle(
                      color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}