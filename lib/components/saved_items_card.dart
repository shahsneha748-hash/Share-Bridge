import 'package:flutter/material.dart';

class SavedItemCard extends StatelessWidget {
  final Function(bool)? onBookmarkToggle;
  final String title;
  final String imagePath;
  final List<String> images;    // full list (may be empty)
  final String miles;
  final String addedTime;
  final bool isBookmarked;

  const SavedItemCard({
    super.key,
    this.onBookmarkToggle,
    required this.title,
    required this.imagePath,
    required this.images,
    required this.miles,
    required this.addedTime,
    this.isBookmarked = false,
  });

  Widget buildImage(String imagePath, List<String> images) {
    final path = imagePath.isNotEmpty
        ? imagePath
        : (images.isNotEmpty ? images[0] : "");

    if (path.isEmpty) {
      return Container(
        height: 166,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
        ),
      );
    }

    if (path.startsWith("http")) {
      return Image.network(
        path,
        height: 166,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    }

    return Image.asset(
      path,
      height: 166,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
      const Icon(Icons.broken_image, size: 60, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 299,
      width: double.infinity,
      child: Card(
        color: const Color(0XFFecf6e5),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Pass both arguments now
            buildImage(imagePath, images),

            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0XFF435944),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    onBookmarkToggle?.call(!isBookmarked);
                  },
                  icon: const Icon(Icons.bookmark,
                      color: Color(0XFF414439), size: 22),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: Color(0XFF435944)),
                  Text(miles, style: const TextStyle(color: Color(0XFF435944))),
                  const SizedBox(width: 20),
                  Text(
                    addedTime,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0XFF435944),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF435944),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text("Message Donor"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
