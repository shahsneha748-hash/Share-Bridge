import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/repo/block_repo.dart';

class BlockRepoImpl implements BlockRepo {
  final firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _blockedCollection(String blockerUid) {
    return firestore.collection('users').doc(blockerUid).collection('blockedUsers');
  }

  @override
  Future<bool> blockUser(String blockerUid, String blockedUid) async {
    try {
      await _blockedCollection(blockerUid).doc(blockedUid).set({
        'blockedUid': blockedUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> unblockUser(String blockerUid, String blockedUid) async {
    try {
      await _blockedCollection(blockerUid).doc(blockedUid).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> isBlocked(String blockerUid, String blockedUid) async {
    try {
      final doc = await _blockedCollection(blockerUid).doc(blockedUid).get();
      return doc.exists;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<List<String>> getBlockedUserIds(String blockerUid) async {
    try {
      final snapshot = await _blockedCollection(blockerUid).get();
      return snapshot.docs.map((d) => d.id).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<List<Map<String,dynamic>>> getBlockedUsers(
      String blockerUid
      ) async {

    try {

      final snapshot =
      await _blockedCollection(blockerUid).get();


      return snapshot.docs.map((doc){

        return {
          'uid': doc.id,
          ...doc.data(),
        };

      }).toList();


    } catch(e){

      print(e);
      return [];

    }

  }

}