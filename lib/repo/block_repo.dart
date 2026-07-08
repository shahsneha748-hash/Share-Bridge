abstract class BlockRepo {
  Future<bool> blockUser(
      String blockerUid,
      String blockedUid, {
        String? fullName,
        String? profilePicture,
      });

  Future<bool> unblockUser(String blockerUid, String blockedUid);

  Future<bool> isBlocked(String blockerUid, String blockedUid);

  Future<List<String>> getBlockedUserIds(String blockerUid);

  Future<List<Map<String, dynamic>>> getBlockedUsers(String blockerUid);
}