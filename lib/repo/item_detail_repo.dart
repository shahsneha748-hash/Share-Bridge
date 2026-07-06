abstract class ItemDetailRepo {
  /// Toggles follow state for a donor — placeholder until backend exists.
  Future<bool> toggleFollow(String donorName, bool currentlyFollowing);

  /// Reports an item — placeholder until backend exists.
  Future<void> reportItem(String itemTitle);

  /// Blocks a donor — placeholder until backend exists.
  Future<void> blockDonor(String donorName);

  /// Sends a request for the item to the donor.
  Future<void> sendRequest(String itemTitle, String donorName);


}