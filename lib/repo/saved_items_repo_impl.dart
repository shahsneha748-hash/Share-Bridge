import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/model/saved_items_model.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';

class SavedItemRepoImpl implements SavedItemRepo {
  final FirebaseFirestore firestore;

  SavedItemRepoImpl({required this.firestore});

  @override
  Future<void> saveItem(SavedItemsModel item) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await firestore
        .collection("users")
        .doc(uid)
        .collection("saved_items")
        .doc(item.id) // use the model’s id
        .set(item.toMap());
  }

  @override
  Future<void> addBookmark(String uid, SavedItemsModel item) async {
    await firestore
        .collection("users")
        .doc(uid)
        .collection("saved_items")
        .doc(item.id)
        .set(item.toMap());
  }

  @override
  Future<void> removeBookmark(String uid, String itemId) async {
    await firestore
        .collection("users")
        .doc(uid)
        .collection("saved_items")
        .doc(itemId)
        .delete();
  }

  @override
  Stream<List<SavedItemsModel>> getBookmarks(String uid) {
    return firestore
        .collection("users")
        .doc(uid)
        .collection("saved_items")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => SavedItemsModel.fromMap(doc.data()))
        .toList());
  }
}

