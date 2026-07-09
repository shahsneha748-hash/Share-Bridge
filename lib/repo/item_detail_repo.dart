abstract class ItemDetailRepo {
  Future<void> reportItem(String itemTitle);
  Future<void> blockDonor(String donorName);
  Future<void> sendRequest(Map<String, dynamic> item);
  Future<String?> getDonorProfilePicture(String donorId);
}