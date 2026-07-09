import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

class UserRepoImpl implements UserRepo {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.uid)
        .set(userModel.toMap());
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
    return firestore.collection("users").doc(userModel.uid).update(userModel.toMap());
  }

  @override
  Future<void> forgetpassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final users = await firestore.collection("users").get();
    List<UserModel> data = [];

    for (int i = 0; i < users.docs.length; i++) {
      data.add(UserModel.fromMap(users.docs[i].data()));
    }
    return data;
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final users = await firestore.collection("users").doc(id).get();
    final data = users.data();

    if (data == null) {
      throw Exception("Unable to fetch data");
    }
    return UserModel.fromMap(data);
  }

  @override
  Future<String> login(String email, String password) async {
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;

    if (userId == null) {
      throw Exception("Login failed");
    }

    final doc = await firestore.collection("users").doc(userId).get();
    final asked = doc.data()?["notificationsAsked"] ?? false;

    if (!asked) {
      await NotificationService.requestPermissionOnce();
      await firestore.collection("users").doc(userId).set({
        "notificationsAsked": true,
      }, SetOptions(merge: true));
    }

    return userId;
  }

  @override
  Future<void> logout() {
    return auth.signOut();
  }

  @override
  Future<String> signup(String email, String password) async {
    final user = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;

    if (userId == null) {
      throw Exception("Registration failed");
    }

    await firestore.collection("users").doc(userId).set({
      "email": email,
      "notificationsAsked": false,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return userId;
  }

  @override
  Future<String> getReceiverName(String receiverId) async {
    final doc = await firestore.collection("users").doc(receiverId).get();
    return doc.data()?['name'] ?? "Unknown User";
  }

  @override
  Future<String?> getProfilePicture(String senderId) async {
    try {
      final doc = await firestore.collection("users").doc(senderId).get();
      if (doc.exists) {
        return doc.data()?["profilePicture"] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching profile picture: $e");
      return null;
    }
  }

}

