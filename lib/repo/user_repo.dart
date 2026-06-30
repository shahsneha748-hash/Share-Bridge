import 'package:sharebridge/model/user_model.dart';

abstract class UserRepo {
  Future<String> login (String email, String password);
  Future<String> signup (String email, String password);
  Future<void> logout();
  Future<void> forgetpassword(String email);
  Future<void> addUser(UserModel userModel);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> getAllUsers();          // list of usermodel leh derai string id return garcha
  Future<UserModel> getUserById(String id);       // usermodel leh euta matrai string id return garcha
  Future<void> editProfile(UserModel userModel);
  Future<String> getReceiverName(String receiverId);
  Future<String?> getProfilePicture(String senderId);
}
