import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  final double size;
  final bool isOnline;
  final String? imageUrl;


  const DefaultAvatar({
    super.key,
    this.size = 50,
    this.isOnline = false,
    this.imageUrl,

  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(imageUrl!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: imageUrl == null || imageUrl!.isEmpty
              ? Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: size * 0.62,
          )
              : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}