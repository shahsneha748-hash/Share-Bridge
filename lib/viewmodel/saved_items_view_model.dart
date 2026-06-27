import 'package:flutter/material.dart';
import 'package:sharebridge/model/saved_items_model.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';

class SavedItemViewModel extends ChangeNotifier {
  final SavedItemRepo repo;
  final String uid;

  SavedItemViewModel({
    required this.repo,
    required this.uid,
  });

  String? _error;
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  List<SavedItemsModel>? _savedItems;
  List<SavedItemsModel>? get savedItems => _savedItems;

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<bool> saveItem(SavedItemsModel item) async {
    setLoading(true);
    setError(null);
    try {
      await repo.saveItem(item);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Stream<List<SavedItemsModel>> get savedItemsStream =>
      repo.getBookmarks(uid);

  Future<void> toggleBookmark(SavedItemsModel item, bool isBookmarked) async {
    try {
      if (isBookmarked) {
        await repo.removeBookmark(uid, item.id);
      } else {
        await repo.addBookmark(uid, item);
      }
    } catch (e) {
      setError(e.toString());
    }
    notifyListeners();
  }
}

