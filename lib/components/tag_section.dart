import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_section.dart';

class TagSection extends StatelessWidget {
  final List<String> tags;
  final VoidCallback onAddTag;
  final Function(String) onRemoveTag;

  const TagSection({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: "Tag",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...tags.map((tag) => Chip(
            label: Text(tag),
            backgroundColor: AppColors.paleGreen,
            onDeleted: () => onRemoveTag(tag),
          )),
          GestureDetector(
            onTap: onAddTag,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text("Add tag"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}