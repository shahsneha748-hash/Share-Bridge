import 'package:flutter/material.dart';
import 'package:sharebridge/components/saved_item_card.dart';
import 'package:sharebridge/viewmodel/saved_items_view_model.dart';
//import 'package:sharebridge/view/donation_chat_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  int currentIndex = 0;
  final PageController pageController = PageController();
  String selectedCategory = "All";

  final List<Map<String, String>> items = [
    {
      "title": "Fruit Basket",
      "image": "assets/images/fruits1.png",
      "category": "Food",
      "miles": "0.4 miles",
      "added time": "Added 2h ago"
    },
    {
      "title": "Books",
      "image": "assets/images/books1.png",
      "category": "Books",
      "miles": "1.2 miles",
      "added time": "Added 10h ago"
    },
    {
      "title": "Bakery Items",
      "image": "assets/images/bakery_items1.png",
      "category": "Food",
      "miles": "0.8 miles",
      "added time": "Added 1 day ago"
    },
    {
      "title": "Grocery Items",
      "image": "assets/images/groceries1.png",
      "category": "Food",
      "miles": "0.5 miles",
      "added time": "Added 2 days ago"
    },
    {
      "title": "Sweater",
      "image": "assets/images/sweater1.png",
      "category": "Clothes",
      "miles": "2.1 miles",
      "added time": "Added 20h ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // filter items based on selectedCategory
    final filteredItems = selectedCategory == "All"
        ? items
        : items.where((item) => item["category"] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0XFF435944),
        foregroundColor: Colors.white,
        title: Text(
          "Saved Items",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        controller: pageController,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8, right: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Collection",
                    style: TextStyle(
                        color: Color(0XFF435944),
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text("Items you have bookmarked for later.",
                    style: TextStyle(
                        color: Color(0XFF435944),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 15),

                // Filter buttons
                Row(
                  children: [
                    buildFilterButton("All"),
                    buildFilterButton("Food"),
                    buildFilterButton("Books"),
                    buildFilterButton("Clothes"),
                  ],
                ),

                SizedBox(height: 10),

                // Render saved cards
                ...filteredItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SavedItemCard(
                    title: item["title"]!,
                    imagePath: item["image"]!,
                    miles: item["miles"]!,
                    addedTime: item["added time"]!,
                  ),
                )),
               ],
            ),
          ),
        ],
      ),
    );
  }

  // reusable filter button
  Widget buildFilterButton(String category) {
    final bool isSelected = selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0XFF435944) : Color(0XFFf2ead3),
          foregroundColor: isSelected ? Colors.white : Color(0XFF435944),
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

