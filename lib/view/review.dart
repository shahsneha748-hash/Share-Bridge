import 'package:flutter/material.dart';

class RatingsReviewsPage extends StatefulWidget {
  const RatingsReviewsPage({super.key});

  @override
  State<RatingsReviewsPage> createState() => _RatingsReviewsPageState();
}

class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  int selectedFilter = 0;
  int selectedRating = 0;

  final TextEditingController reviewController = TextEditingController();

  List<Map<String, dynamic>> reviews = [
    {
      "name": "Shena",
      "initials": "BN",
      "rating": 5,
      "time": "2 days ago",
      "date": "May 22, 2026",
      "likes": 14,
      "liked": false,
      "review":
      "Amazing experience! The item was exactly as described and in perfect condition. Very grateful!"
    },
    {
      "name": "Alex",
      "initials": "AL",
      "rating": 4,
      "time": "3 days ago",
      "date": "May 20, 2026",
      "likes": 9,
      "liked": false,
      "review":
      "Really good and respectful handover. The donor was communicative and kind. Would highly recommend."
    },
    {
      "name": "Sam",
      "initials": "BA",
      "rating": 3,
      "time": "1 week ago",
      "date": "May 15, 2026",
      "likes": 5,
      "liked": false,
      "review":
      "Good overall. Item was decent but packaging could be better next time."
    },
    {
      "name": "Priya",
      "initials": "PR",
      "rating": 2,
      "time": "2 weeks ago",
      "date": "May 10, 2026",
      "likes": 2,
      "liked": false,
      "review":
      "Item condition was not as described. Expected better quality."
    },
    {
      "name": "Tom",
      "initials": "TO",
      "rating": 1,
      "time": "3 weeks ago",
      "date": "May 02, 2026",
      "likes": 1,
      "liked": false,
      "review":
      "Very disappointed. Item was damaged and unusable when received."
    },
  ];

  List<Map<String, dynamic>> get filteredReviews {
    if (selectedFilter == 0) return reviews;

    return reviews
        .where((review) => review['rating'] == selectedFilter)
        .toList();
  }

  void submitReview() {
    if (selectedRating == 0 || reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add rating and review"),
        ),
      );
      return;
    }

    setState(() {
      reviews.insert(0, {
        "name": "You",
        "initials": "YU",
        "rating": selectedRating,
        "time": "Just now",
        "date": "Today",
        "likes": 0,
        "liked": false,
        "review": reviewController.text,
      });

      selectedRating = 0;
      reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Review submitted successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f4ee),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Ratings & Reviews",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ITEM IMAGE + NAME CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CLOTH IMAGE
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

                  // ITEM NAME
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
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // TOP CARD
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
                      const Text(
                        "3.0",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                              (index) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${reviews.length} reviews",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      children: [
                        buildRatingBar(5, 0.9, Colors.green),
                        buildRatingBar(4, 0.7, Colors.lightGreen),
                        buildRatingBar(3, 0.5, Colors.orange),
                        buildRatingBar(2, 0.3, Colors.deepOrange),
                        buildRatingBar(1, 0.2, Colors.red),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FILTERS IN ONE ROW
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "${filteredReviews.length}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Column(
              children: filteredReviews.map((review) {
                return reviewCard(review);
              }).toList(),
            ),

            const SizedBox(height: 25),

            // WRITE REVIEW
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Share your experience with this donor",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CLICKABLE STARS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
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
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                      "Share your experience with this donor...",
                      filled: true,
                      fillColor: const Color(0xfff3f5f2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildRatingBar(int star, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$star",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "1",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String text, int value) {
    bool selected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
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

  Widget reviewCard(Map<String, dynamic> review) {
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
                  review['initials'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review['time'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
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
                  "+${review['rating']}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star,
                size: 16,
                color: index < review['rating']
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
            child: Text(
              review['review'],
              style: const TextStyle(height: 1.5),
            ),
          ),

          const SizedBox(height: 12),

          // CLICKABLE HEART
          GestureDetector(
            onTap: () {
              setState(() {
                review['liked'] = !review['liked'];

                if (review['liked']) {
                  review['likes']++;
                } else {
                  review['likes']--;
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  review['liked']
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                  review['liked'] ? Colors.red : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  "${review['likes']} people found this helpful",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}