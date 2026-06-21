import 'package:sharebridge/repo/item_detail_repo.dart';

class ItemDetailRepoImpl implements ItemDetailRepo {
  @override
  Future<bool> toggleFollow(String donorName, bool currentlyFollowing) async {
    // TODO: connect to Firebase later — for now just flips locally
    await Future.delayed(const Duration(milliseconds: 150));
    return !currentlyFollowing;
  }

  @override
  Future<void> reportItem(String itemTitle) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> blockDonor(String donorName) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> sendRequest(String itemTitle, String donorName) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}