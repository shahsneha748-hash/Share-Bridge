import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../repo/saved_items_repo_impl.dart';
import '../view/donation_chat_screen.dart';
import '../view/item_detail_screen.dart';
import '../viewmodel/browse_view_model.dart';

class SavedItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isBookmarked;
  final Function(bool)? onBookmarkToggle;

  const SavedItemCard({
    super.key,
    required this.item,
    this.isBookmarked = true,
    this.onBookmarkToggle,
  });

  Widget buildImage() {
    final List<String> images =
    List<String>.from(item["images"] ?? []);

    final String imagePath =
        item["image"] ??
            (images.isNotEmpty ? images.first : "");

    if (imagePath.isEmpty) {
      return Container(
        height: 166,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        height: 166,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, size: 60),
      );
    }

    return Image.asset(
      imagePath,
      height: 166,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
      const Icon(Icons.broken_image, size: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = item["title"] ?? "";
    final donorId = item["donorId"] ?? "";
    final donorName = item["donorName"] ?? "";
    final miles = item["miles"] ?? "";
    final addedTime = item["addedTime"] ?? "";

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: GestureDetector(onTap: () async {
        final donationId = item["id"];

        if (donationId == null || donationId.toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Donation not found."),
            ),
          );
          return;
        }

        final doc = await FirebaseFirestore.instance
            .collection("donations")
            .doc(donationId)
            .get();

        if (!doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This donation has been removed."),
            ),
          );
          return;
        }

        final data = doc.data()!;

        // Get donor information
        final userId = data["userId"] ?? "";

        String donorName = "Unknown";
        double donorRating = 0.0;
        int donorDonations = 0;

        if (userId.toString().isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;

            donorName = userData["fullName"] ?? "Unknown";
            donorRating =
                (userData["rating"] as num?)?.toDouble() ?? 0.0;
            donorDonations =
                userData["totalDonations"] ?? 0;
          }
        }

        final images =
        List<String>.from(data["images"] ?? []);

        final browseItem = {
          "id": doc.id,
          "title": data["itemName"] ?? "",
          "images": images,
          "image": images.isNotEmpty ? images.first : null,
          "available": data["status"] == "available",
          "isDonated": data["status"] == "claimed",
          "status": data["status"],
          "acceptedAt": data["acceptedAt"],
          "category": data["category"] ?? "Others",
          "location": data["location"] ?? "",
          "shortLocation":
          (data["location"] ?? "").toString().split(",").first,
          "description": data["description"] ?? "",
          "condition": data["condition"] ?? "",
          "weight": data["weight"] ?? "",
          "note": data["note"] ?? "",
          "tags": List<String>.from(data["tags"] ?? []),
          "createdAt": data["createdAt"],
          "userId": userId,
          "donorId": userId,
          "donorName": donorName,
          "donorRating": donorRating,
          "donorDonations": donorDonations,
          "portion": data["portionCount"] != null
              ? "${data["portionCount"]} people"
              : "",
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(
              item: browseItem,
            ),
          ),
        );
      },
        child: Card(
          color: const Color(0XFFECF6E5),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildImage(),

              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(item: item),
                        ),
                      );
                    },
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
                    icon: const Icon(
                      Icons.bookmark,
                      color: Color(0XFF414439),
                    ),
                    onPressed: () async {
                      final uid =
                          FirebaseAuth.instance.currentUser!.uid;

                      await SavedItemRepoImpl(
                        firestore: FirebaseFirestore.instance,
                      ).removeBookmark(
                        uid,
                        title,
                      );

                      context
                          .read<BrowseViewModel>()
                          .toggleFavorite(title);

                      onBookmarkToggle?.call(false);
                    },
                  ),
                ],
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0XFF435944),
                    ),
                    Text(
                      miles,
                      style: const TextStyle(
                        color: Color(0XFF435944),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      addedTime,
                      style: const TextStyle(
                        color: Color(0XFF435944),
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFF435944),
              //       foregroundColor: const Color(0XFFF5F0E8),),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => DonationChatScreen(
              //             chatId:
              //             "savedItem_${donorId}_${item["id"]}",
              //             otherUserId: donorId,
              //             otherUserName: donorName,
              //             itemName: title,
              //           ),
              //         ),
              //       );
              //     },
              //     child: Row(
              //       mainAxisAlignment:
              //       MainAxisAlignment.center,
              //       children: const [
              //         Icon(
              //           Icons.chat_bubble_outline,
              //           color: Color(0XFFF5F0E8),
              //           size: 18,
              //         ),
              //         SizedBox(width: 6),
              //         Text(
              //           "Message",
              //           style: TextStyle(
              //             color: Color(0XFFF5F0E8),
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}