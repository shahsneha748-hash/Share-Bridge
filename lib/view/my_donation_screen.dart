import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ASSUMPTION: a top-level "donations" collection with documents shaped like:
// { donorId, title, category, status, imageUrl, createdAt }
// Adjust field names below if your actual schema differs.
class MyDonationsScreen extends StatelessWidget {
  final String uid;
  const MyDonationsScreen({super.key, required this.uid});

  static const Color kPrimary = Color(0xFF2D5A27);
  static const Color kTextGrey = Color(0xFF7A8A78);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text('My Donations', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("donations")
            .where("userId", isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimary));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text("You haven't shared any items yet.",
                  style: TextStyle(color: kTextGrey)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled item';
              final status = data['status'] ?? 'Pending';
              final category = data['category'] ?? '';
              final createdAt = data['createdAt'];
              String dateLabel = '';
              if (createdAt is Timestamp) {
                final d = createdAt.toDate();
                dateLabel = '${d.day}/${d.month}/${d.year}';
              }
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Donation Image
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kPrimary.withOpacity(0.1),
                      ),
                      child: data['images'] != null &&
                          (data['images'] as List).isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['images'][0],
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(
                        Icons.volunteer_activism,
                        color: kPrimary,
                        size: 35,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Category: $category",
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextGrey,
                            ),
                          ),

                          Text(
                            "Location: ${data['location'] ?? 'Not added'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextGrey,
                            ),
                          ),

                          Text(
                            "Condition: ${data['condition'] ?? 'Not added'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: kTextGrey,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kTextGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          color: kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}