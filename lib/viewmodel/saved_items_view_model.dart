import 'package:flutter/material.dart';
import 'package:sharebridge/model/saved_items_model.dart';
import 'package:sharebridge/repo/saved_items_repo.dart';

class SavedItemViewModel extends ChangeNotifier {
  final SavedItemRepo _savedItemRepo;

  SavedItemViewModel({required SavedItemRepo savedItemRepo
  }) : _savedItemRepo = savedItemRepo;

  String? _error;
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  SavedItem? _selectedsavedItems;
  SavedItem? get selectedsavedItems => _selectedsavedItems;

  List<SavedItem>? _savedItems;
  List<SavedItem>? get savedItems => _savedItems;

  void setError(String? error){
    _error = error;
    notifyListeners();
  }

  void setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<bool> saveItem(SavedItem item) async{
    setLoading(true);
    setError(null);
    try {
      await _savedItemRepo.saveItem(item);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    }finally{
      setLoading(false);
    }
  }

  Future<void> getSavedItems() async {
    setLoading(true);
    setError(null);
    try {
      _savedItems = await _savedItemRepo.getSavedItems();
    } on Exception catch (e) {
      setError(e.toString());
    }finally{
      setLoading(false);
    }
  }
}
