import 'package:flutter/material.dart';
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
  String selectedCategory = "All";   // <-- added

  final List<Map<String, String>> items = [
    {"title": "Fruit Basket", "image": "assets/images/fruits.png", "category": "Food"},
    {"title": "Books", "image": "assets/images/books.png", "category": "Books"},
    {"title": "Bakery Items", "image": "assets/images/bakery_items.png", "category": "Food"},
    {"title": "Grocery Items", "image": "assets/images/groceries.png", "category": "Food"},
    {"title": "Sweater", "image": "assets/images/sweater.png", "category": "Clothes"},
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

                SizedBox(height: 15),

                // Use filteredItems here
                ...filteredItems.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: buildItemCard(
                      0, item["title"]!, item["image"]!),
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

  Widget buildItemCard(int index, String title, String imagePath) {
    return SizedBox(
      height: 130,
      child: Card(
        color: Color(0XFFecf6e5),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Color(0XFF6a965b)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 100, width: 100),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0XFF435944),
                          fontWeight: FontWeight.w700)),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF435944),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: Text("Message Donor")),
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.bookmark,
                    color: Color(0XFF757575), size: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

