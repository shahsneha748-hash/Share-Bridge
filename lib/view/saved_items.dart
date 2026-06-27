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
  int currentIndex = 0;
  final PageController pageController = PageController();
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0XFF435944),
        foregroundColor: Colors.white,
        title: const Text(
          "Saved Items",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("saved_items")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // Filter by category
          final filteredItems = selectedCategory == "All"
              ? docs
              : docs.where((d) => d["category"] == selectedCategory).toList();

          return ListView(
            controller: pageController,
            padding: const EdgeInsets.all(10),
            children: [
              // Header
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

              // Filter buttons (always visible)
              Row(
                children: [
                  buildFilterButton("All"),
                  buildFilterButton("Food"),
                  buildFilterButton("Books"),
                  buildFilterButton("Clothes"),
                ],
              ),
              const SizedBox(height: 10),

              // Saved items list (conditionally visible)
              if (filteredItems.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.only(top: 280),
                  child: Text("No saved items yet."),
                ))
              else
                ...filteredItems.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: SavedItemCard(
                      title: data["title"] ?? "",
                      imagePath: data["image"] ?? "",
                      miles: data["miles"] ?? "",
                      addedTime: data["addedTime"] ?? "",
                      isBookmarked: true,
                      onBookmarkToggle: (isBookmarked) {
                        if (!isBookmarked) {
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
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

  // reusable filter button
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

