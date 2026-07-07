import 'package:flutter/material.dart';

abstract class ItemDetailRepo {
  Future<bool> toggleFollow(String donorName, bool currentlyFollowing);
  Future<void> reportItem(String itemTitle);
  Future<void> blockDonor(String donorName);
  Future<void> sendRequest(Map<String, dynamic> item);
  Future<String?> getDonorProfilePicture(String donorId);
}