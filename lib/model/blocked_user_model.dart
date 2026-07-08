class BlockedUser {
  final String uid;
  final String name;
  final String? profilePicture;

  BlockedUser({
    required this.uid,
    required this.name,
    this.profilePicture,
  });

  factory BlockedUser.fromMap(
      String uid,
      Map<String, dynamic> data,
      ) {
    return BlockedUser(
      uid: uid,
      name: data['fullName'] ?? 'Unknown',
      profilePicture: data['profilePicture'],
    );
  }
}