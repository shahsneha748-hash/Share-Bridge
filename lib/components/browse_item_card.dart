import 'package:flutter/material.dart';
import 'package:sharebridge/constants/colors.dart';

class BrowseItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const BrowseItemCard({
    super.key,
    required this.item,
    required this.isSaved,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool available = item['available'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.paleGreen, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: available ? AppColors.paleGreen : AppColors.takenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      available ? 'Available' : 'Taken',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: available
                            ? AppColors.availableText
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: available ? onFavoriteTap : null,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: available
                          ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isSaved
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(isSaved),
                          size: 18,
                          color: AppColors.darkGreen,
                        ),
                      )
                          : Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.paleGreen,
                    child: Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.darkGreen,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        item['distance'] ?? '—',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}