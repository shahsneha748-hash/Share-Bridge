import 'package:cloudinary_public/cloudinary_public.dart';
import 'image_repo.dart';

class ImageRepoImpl implements ImageRepo {
  final cloudinary = CloudinaryPublic(
    "dszqopqgg",
    "sharebridge",
    cache: false,
  );

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print("Cloudinary upload error: $e");
      rethrow;
    }
  }
}