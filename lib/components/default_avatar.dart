import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  final double size;
  final bool isOnline;

  const DefaultAvatar({
    super.key,
    this.size = 50,
    this.isOnline = false,
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
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: size * 0.62,
          ),
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