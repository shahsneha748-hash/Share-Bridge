import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/components/saved_items_card.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0XFF435944),
        foregroundColor: Color(0XFFf5f0e8),
        title: const Text(
          "Wishlist",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("saved_items")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No saved items yet."));
          }

          final docs = snapshot.data!.docs;

          // Filter by category
          final filteredItems = selectedCategory == "All"
              ? docs
              : docs.where((d) => d["category"] == selectedCategory).toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const Text("My Collection",
                  style: TextStyle(
                      color: Color(0XFF435944),
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const Text("Items you have bookmarked for later.",
                  style: TextStyle(
                      color: Color(0XFF435944),
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 15),

              // Filter buttons
              // Replace your Row with this:
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildFilterButton("All"),
                    buildFilterButton("Food"),
                    buildFilterButton("Clothes"),
                    buildFilterButton("Stationery"),
                    buildFilterButton("Others"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Saved items list
              if (filteredItems.isEmpty)
                const Center(child: Text("No saved items in this category."))
              else
                ...filteredItems.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // 👇 Safely extract both image and images
                  final List<String> images =
                  (data["images"] != null) ? List<String>.from(data["images"]) : [];

                  final String imagePath =
                      data["image"] ?? (images.isNotEmpty ? images[0] : "");
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    

                    child: SavedItemCard(
                      title: data["title"] ?? "",
                      imagePath: imagePath,   // ✅ fallback to single "image"
                      images: images,         // ✅ pass full list if available
                      miles: data["miles"] ?? "",
                      addedTime: data["addedTime"] ?? "",
                      isBookmarked: true,
                      onBookmarkToggle: (isBookmarked) {
                        if (!isBookmarked) {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("saved_items")
                              .doc(doc.id)
                              .delete();
                        }
                      },
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget buildFilterButton(String category) {
    final bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSelected ? const Color(0XFF435944) : const Color(0XFFf2ead3),
          foregroundColor:
          isSelected ? Colors.white : const Color(0XFF435944),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Text(category),
      ),
    );
  }
}


