import 'package:sharebridge/model/saved_items_model.dart';

abstract class SavedItemRepo {
  Future<void> saveItem(SavedItemsModel item);
  Future<void> addBookmark(String uid, SavedItemsModel item);
  Future<void> removeBookmark(String uid, String itemId);
  Stream<List<SavedItemsModel>> getBookmarks(String uid);
}

