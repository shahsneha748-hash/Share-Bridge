import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/model/saved_items_model.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';

class SavedItemRepositoryImpl implements SavedItemRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<List<SavedItem>> getSavedItems() async{
    final savedItems = await firestore.collection('saved_items').get();
    return savedItems.docs.map((doc) => SavedItem.fromMap(doc.data())).toList();
  }

  @override
  Future<void> removeItem(String id) {
    return firestore
        .collection('saved_items')
        .doc(id)
        .delete();
  }

  @override
  Future<void> saveItem(SavedItem item) {
    return firestore
        .collection('saved_items')
        .doc(item.id)
        .set(item.toMap());
  }
  
}
