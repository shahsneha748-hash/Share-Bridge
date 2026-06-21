import 'package:sharebridge/model/saved_items_model.dart';

abstract class SavedItemRepo {
  Future<void> saveItem(SavedItem item);
  Future<void> removeItem(String id);
  Future<List<SavedItem>> getSavedItems();
}
