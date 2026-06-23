import 'package:flutter/material.dart';
import '../model/request_system_model.dart';
import '../repo/request_system_repo.dart';

class RequestSystemViewModel extends ChangeNotifier {
  final RequestSystemRepo repo;

  RequestSystemViewModel(this.repo);

  // controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  String category = "food";
  bool isCompleted = false;
  bool isLoading = false;
  bool submitted = false;
  bool confirmDelete = false;

  List<RequestSystemModel> requests = [];

  final categories = const [
    {'id': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'id': 'stationery', 'label': 'Stationery', 'icon': Icons.edit},
    {'id': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'id': 'other', 'label': 'Other', 'icon': Icons.apps_rounded},
  ];

  void setCategory(String val) {
    category = val;
    notifyListeners();
  }

  void toggleCompleted() {
    isCompleted = !isCompleted;
    notifyListeners();
  }

  bool get canSubmit =>
      nameController.text.isNotEmpty &&
          titleController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          locationController.text.isNotEmpty;

  void handleDelete() {
    confirmDelete = !confirmDelete;
    notifyListeners();
  }

  Future<void> submit() async {
    if (!canSubmit) return;

    isLoading = true;
    notifyListeners();

    final model = RequestSystemModel(
      id: "",
      name: nameController.text,
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      category: category,
      isCompleted: isCompleted,
    );

    await repo.add(model);

    isLoading = false;
    submitted = true;
    notifyListeners();
  }

  void reset() {
    nameController.clear();
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    category = "food";
    isCompleted = false;
    submitted = false;
    confirmDelete = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }
}