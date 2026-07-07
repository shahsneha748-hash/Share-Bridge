import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : "?";

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2D5A27).withOpacity(0.15),
        image: hasImage
            ? DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: hasImage
          ? null
          : Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D5A27),
          ),
        ),
      ),
    );
  }
}