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
            .collection('donations')
            .where('donorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
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
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.volunteer_activism, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('$category · $dateLabel', style: const TextStyle(fontSize: 12, color: kTextGrey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(status, style: const TextStyle(fontSize: 11, color: kPrimary, fontWeight: FontWeight.w600)),
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