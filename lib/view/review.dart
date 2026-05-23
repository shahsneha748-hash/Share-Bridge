import 'package:flutter/material.dart';

class RatingReviewPage extends StatefulWidget {
  const RatingReviewPage({super.key});

  @override
  State<RatingReviewPage> createState() => _RatingReviewPageState();
}

class _RatingReviewPageState extends State<RatingReviewPage> {
  static const Color kPrimary   = Color(0xFF2D5A27);
  static const Color kBeige     = Color(0xFFF7F4EF);
  static const Color kBeigeDeep = Color(0xFFEEE8DE);
  static const Color kCard      = Color(0xFFFFFFFF);
  static const Color kTextDark  = Color(0xFF1C2B1A);
  static const Color kTextGrey  = Color(0xFF7A8A78);
  static const Color kDivider   = Color(0xFFE4DDD3);
  static const Color kStar      = Color(0xFFF5C842);

  double selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  final List<Map<String, dynamic>> reviews = [
    {"name": "Sneha", "rating": 5, "review": "Amazing experience! The item was exactly as described and in perfect condition.", "date": "2 days ago"},
    {"name": "Alex",  "rating": 4, "review": "Really good and respectful handover. Would highly recommend this donor.",       "date": "5 days ago"},
    {"name": "Sam",   "rating": 3, "review": "Good overall. Item was decent but packaging could be better next time.",         "date": "1 week ago"},
    {"name": "Priya", "rating": 2, "review": "Item condition was not as described. Expected better quality.",                  "date": "2 weeks ago"},
    {"name": "Tom",   "rating": 1, "review": "Very disappointed. Item was damaged and unusable when I received it.",           "date": "3 weeks ago"},
  ];

  void submitReview() {
    if (selectedRating == 0 || reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please give a rating and write a review")),
      );
      return;
    }
    setState(() {
      reviews.insert(0, {
        "name": "You",
        "rating": selectedRating.toInt(),
        "review": reviewController.text.trim(),
        "date": "Just now",
      });
      selectedRating = 0;
      reviewController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully!"), backgroundColor: kPrimary),
    );
  }

  double get avgRating => reviews.isEmpty
      ? 0
      : reviews.map((r) => (r['rating'] as int).toDouble()).reduce((a, b) => a + b) / reviews.length;

  int _countFor(int star) => reviews.where((r) => r['rating'] == star).length;

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent!';
      default: return '';
    }
  }

  Color _starColor(int star) {
    switch (star) {
      case 5: return const Color(0xFF4CAF50);
      case 4: return const Color(0xFF8BC34A);
      case 3: return const Color(0xFFFFC107);
      case 2: return const Color(0xFFFF9800);
      case 1: return const Color(0xFFF44336);
      default: return kStar;
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeige,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text("Ratings & Reviews",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Rating Summary ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Score + stars
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < avgRating.floor()
                              ? Icons.star
                              : (i < avgRating ? Icons.star_half : Icons.star_border),
                          color: kStar,
                          size: 17,
                        )),
                      ),
                      const SizedBox(height: 5),
                      Text('${reviews.length} reviews',
                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Bar breakdown
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = _countFor(star);
                        final frac = reviews.isEmpty ? 0.0 : count / reviews.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text('$star',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white60)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: frac,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        _starColor(star)),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 16,
                                child: Text('$count',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white60),
                                    textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Star breakdown tiles ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = _countFor(star);
                  final frac = reviews.isEmpty ? 0.0 : count / reviews.length;
                  final pct = (frac * 100).round();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Star label
                        Row(
                          children: [
                            Icon(Icons.star, color: _starColor(star), size: 16),
                            const SizedBox(width: 4),
                            Text('$star',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kTextDark)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Bar
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: frac,
                              backgroundColor: kBeigeDeep,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _starColor(star)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Count + pct
                        SizedBox(
                          width: 52,
                          child: Text(
                            '$count ($pct%)',
                            style: const TextStyle(
                                fontSize: 12, color: kTextGrey),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Write a Review ────────────────────────────────────────
            const Text("Write a Review",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                children: [
                  // Star picker
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: kBeige,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final val = i + 1;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedRating = val.toDouble()),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              val <= selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 36,
                              color: val <= selectedRating
                                  ? kStar
                                  : kDivider,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  if (selectedRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _ratingLabel(selectedRating.toInt()),
                      style: const TextStyle(
                          fontSize: 13,
                          color: kPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],

                  const SizedBox(height: 16),

                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    style:
                    const TextStyle(fontSize: 14, color: kTextDark),
                    decoration: InputDecoration(
                      hintText: "Share your experience...",
                      hintStyle:
                      const TextStyle(color: kTextGrey, fontSize: 14),
                      filled: true,
                      fillColor: kBeige,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: kPrimary, width: 1),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      child: const Text("Submit Review"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── User Reviews ──────────────────────────────────────────
            Row(
              children: [
                const Text("User Reviews",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: kBeigeDeep,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${reviews.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kPrimary)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ListView.separated(
              itemCount: reviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = reviews[index];
                final star = r['rating'] as int;
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kDivider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: kBeigeDeep,
                            child: Text(
                              (r['name'] as String)[0].toUpperCase(),
                              style: const TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kTextDark,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(r['date'] as String,
                                    style: const TextStyle(
                                        color: kTextGrey, fontSize: 12)),
                              ],
                            ),
                          ),
                          // Rating badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _starColor(star).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    color: _starColor(star), size: 14),
                                const SizedBox(width: 3),
                                Text('$star',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _starColor(star))),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < star ? Icons.star : Icons.star_border,
                          color: i < star ? _starColor(star) : kDivider,
                          size: 16,
                        )),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBeige,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r['review'] as String,
                          style: const TextStyle(
                              color: kTextGrey, height: 1.6, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
