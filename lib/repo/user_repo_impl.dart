import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/service/notification_service.dart';

class UserRepoImpl implements UserRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final NotificationService notificationService;

  UserRepoImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    NotificationService? notificationService,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        notificationService = notificationService ?? NotificationService();

  @override
  Future<void> addUser(UserModel userModel) {
    return firestore.collection("users").doc(userModel.uid).set(userModel.toMap());
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
    return users.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final doc = await firestore.collection("users").doc(id).get();
    final data = doc.data();
    if (data == null) throw Exception("Unable to fetch data");
    return UserModel.fromMap(data);
  }

  @override
  Future<String> login(String email, String password) async {
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;
    if (userId == null) throw Exception("Login failed");

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
  Future<void> logout() => auth.signOut();

  @override
  Future<String> signup(String email, String password) async {
    final user = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;
    if (userId == null) throw Exception("Registration failed");

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
    final doc = await firestore.collection("users").doc(senderId).get();
    return doc.data()?["profilePicture"] as String?;
  }
}