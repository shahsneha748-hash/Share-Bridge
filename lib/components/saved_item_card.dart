import 'package:flutter/material.dart';

class SavedItemCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String miles;
  final String addedTime;

  const SavedItemCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.miles,
    required this.addedTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 299,
      width: double.infinity,
      child: Card(
        color: Color(0XFFecf6e5),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image full width
            Image.asset(
              imagePath,
              height: 166,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Title + bookmark
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0XFF435944),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    // Later: remove from saved list
                  },
                  icon: Icon(Icons.bookmark,
                      color: Color(0XFF414439), size: 22),
                ),
              ],
            ),

            // Miles + added time
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: Color(0XFF435944)),
                  Text(miles, style: TextStyle(color: Color(0XFF435944))),
                  SizedBox(width: 20),
                  Text(
                    addedTime,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0XFF435944),
                    ),
                  ),
                ],
              ),
            ),

            // Full-width button
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF435944),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Text("Request Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
