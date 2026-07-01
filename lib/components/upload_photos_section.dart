import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_section.dart';

class UploadPhotosSection extends StatelessWidget {
  final List<String> photoUrls;
  final bool uploading;
  final int maxPhotos;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final ValueChanged<String> onRemovePhoto;

  const UploadPhotosSection({
    super.key,
    required this.photoUrls,
    required this.uploading,
    this.maxPhotos = 5,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: "Upload Photos",
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "${photoUrls.length}/$maxPhotos",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      child: Column(
        children: [
          if (photoUrls.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final url = photoUrls[i];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto(url),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (photoUrls.isNotEmpty) const SizedBox(height: 10),

          if (uploading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            )
          else if (photoUrls.length < maxPhotos)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onPickFromGallery,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_outlined, color: AppColors.darkGreen),
                          SizedBox(height: 4),
                          Text("Gallery", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onPickFromCamera,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_outlined, color: AppColors.darkGreen),
                          SizedBox(height: 4),
                          Text("Camera", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          const Text(
            "up to 5 images JPG or PNG",
            style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
          ),
        ],
      ),
    );
  }
}