import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/review_model.dart';
import '../viewmodel/other_profile_view_model.dart';
import '../viewmodel/review_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
class RatingsReviewsPage extends StatefulWidget {
  final String donationId;
  final String targetUserId; // donor/volunteer id
  final String reviewType;
  const RatingsReviewsPage({
    super.key,
    required this.donationId,
    required this.targetUserId,
    required this.reviewType,
  });
  @override
  State<RatingsReviewsPage> createState() => _RatingsReviewsPageState();
}
class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  int selectedFilter = 0;
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool get _isVolunteer => widget.reviewType == 'volunteer';
  String get _targetLabel => _isVolunteer ? 'volunteer' : 'donor';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ReviewViewModel>().getReviewsForUser(widget.targetUserId);
      context.read<OtherProfileViewModel>().fetchProfile(widget.targetUserId);
    });
  }
  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
  void submitReview(ReviewViewModel vm) async {
    final user = FirebaseAuth.instance.currentUser!;
    if (selectedRating == 0 || reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add rating and review")),
      );
      return;
    }
    final userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    final userData = userDoc.data();
    final userName = userData?['fullName'] ?? "User";
    final model = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      donationId: widget.donationId,
      targetUserId: widget.targetUserId,
      reviewType: widget.reviewType,
      reviewerId: user.uid,
      reviewerName: userName,
      reviewerInitials: userName.isNotEmpty ? userName[0].toUpperCase() : "U",
      rating: selectedRating.toDouble(),
      review: reviewController.text,
      createdAt: DateTime.now(),
      likes: 0,
      liked: false,
    );
    await vm.addReview(model);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully")),
    );
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    final profileVM = context.watch<OtherProfileViewModel>();
    final profile = profileVM.profile;
    final filteredReviews = selectedFilter == 0
        ? vm.reviews
        : vm.reviews.where((r) => r.rating.toInt() == selectedFilter).toList();
    return Scaffold(
      backgroundColor: const Color(0xfff1f4ee),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Standard back indicator
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,               // Preserves normal left edge alignments next to the arrow
        title: Text(
          _isVolunteer ? "Rate Volunteer" : "Rate Donor",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── USER CARD ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: profile?.profilePicture != null &&
                        profile!.profilePicture!.isNotEmpty
                        ? NetworkImage(profile.profilePicture!)
                        : null,
                    child: profile?.profilePicture == null ||
                        profile!.profilePicture!.isEmpty
                        ? Text(
                      profile?.fullName.isNotEmpty == true
                          ? profile!.fullName[0].toUpperCase()
                          : "U",
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile?.fullName ?? "User",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isVolunteer ? Colors.blue.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isVolunteer ? Colors.blue.shade200 : Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                _isVolunteer ? 'Volunteer' : 'Donor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isVolunteer ? Colors.blue.shade700 : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile?.address ?? "Location not set",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.volunteer_activism_outlined,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${profile?.totalDonations ?? 0} donations shared",
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: filteredReviews.map((review) => reviewCard(review, vm)).toList(),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Share your experience with this $_targetLabel",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.star,
                            size: 34,
                            color: index < selectedRating ? Colors.orange : Colors.grey.shade300,
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
                      hintText: "Share your experience with this $_targetLabel...",
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
                      onPressed: () => submitReview(vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  review.reviewerInitials,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      review.createdAt.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "+${review.rating.toInt()}",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                color: index < review.rating ? Colors.orange : Colors.grey.shade300,
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
            child: Text(review.review, style: const TextStyle(height: 1.5)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              vm.updateReview(
                ReviewModel(
                  id: review.id,
                  donationId: review.donationId,
                  targetUserId: review.targetUserId,
                  reviewType: review.reviewType,
                  reviewerId: review.reviewerId,
                  reviewerName: review.reviewerName,
                  reviewerInitials: review.reviewerInitials,
                  rating: review.rating,
                  review: review.review,
                  createdAt: review.createdAt,
                  likes: review.liked ? review.likes - 1 : review.likes + 1,
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
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}