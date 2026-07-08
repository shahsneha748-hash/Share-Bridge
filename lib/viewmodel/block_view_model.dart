import 'package:flutter/material.dart';
import '../model/blocked_user_model.dart';
import '../repo/block_repo.dart';


class BlockViewModel extends ChangeNotifier {
  final BlockRepo repo;
  BlockViewModel({
    required this.repo,
  });


  List<BlockedUser> _blockedUsers = [];
  List<BlockedUser> get blockedUsers =>
      _blockedUsers;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchBlockedUsers(
      String uid
      ) async {


    _loading = true;
    notifyListeners();



    final data =
    await repo.getBlockedUsers(uid);



    _blockedUsers =
        data.map((item){

          return BlockedUser(
            uid: item['uid'],
            name: item['fullName'] ?? "Unknown",
            profilePicture:
            item['profilePicture'],
          );

        }).toList();



    _loading = false;
    notifyListeners();

  }




  Future<bool> unblockUser(
      String currentUid,
      String blockedUid
      ) async {

    final success =
    await repo.unblockUser(
      currentUid,
      blockedUid,
    );

    if(success){

      _blockedUsers.removeWhere(
              (user)=>user.uid == blockedUid
      );

      notifyListeners();

    }

    return success;
  }





  Future<bool> blockUser(
      String currentUid,
      String blockedUid, {
        String? fullName,
        String? profilePicture,
      }) {
    return repo.blockUser(
      currentUid,
      blockedUid,
      fullName: fullName,
      profilePicture: profilePicture,
    );
  }


  Future<bool> isBlocked(
      String currentUid,
      String otherUid
      ){

    return repo.isBlocked(
        currentUid,
        otherUid
    );

  }

}