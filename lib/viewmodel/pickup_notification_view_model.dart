import 'package:flutter/material.dart';
import 'package:sharebridge/model/pickup_notification_model.dart';
import 'package:sharebridge/repo/pickup_notification_repo.dart';

class PickupNotificationViewModel extends ChangeNotifier {
  final PickupNotificationRepo _pickupNotificationRepo;

  PickupNotificationViewModel({required PickupNotificationRepo pickupNotificationRepo})
      : _pickupNotificationRepo = pickupNotificationRepo;

  bool _loading = false;

  bool get loading => _loading;

  String? _error;

  String? get error => _error;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  setError(String? value) {
    _error = value;
    notifyListeners();
  }

  //getProductById
  PickupNotificationModel? _pickupNotification;

  PickupNotificationModel? get product => _pickupNotification;

  //getAllProduct
  List<PickupNotificationModel>? _allPickupNotification;

  List<PickupNotificationModel>? get allProducts => _allPickupNotification;

  Future<bool> addPickupNotification(PickupNotificationModel model) async {
    setLoading(true);
    setError(null);
    try {
      await _pickupNotificationRepo.addPickupNotification(model);
      await getAllPickupNotification();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deletePickupNotification(String id) async{
    setLoading(true);
    setError(null);
    try {
      await _pickupNotificationRepo.deletePickupNotification(id);
      await getAllPickupNotification();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> editPickupNotification(PickupNotificationModel model) async{
    setLoading(true);
    setError(null);
    try {
      await _pickupNotificationRepo.editPickupNotification(model);
      await getAllPickupNotification();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> getPickupNotificationByUser(String id) async{
    setLoading(true);
    setError(null);
    try {
      _pickupNotification = await _pickupNotificationRepo.getPickupNotificationsByUser(id);
    } on Exception catch (e) {
      setError(e.toString());
    }finally{
      setLoading(false);
    }
  }

  Future<void> getAllPickupNotification() async{
    setLoading(true);
    setError(null);
    try {
      _allPickupNotification = await _pickupNotificationRepo.getAllPickupNotifications();
    } on Exception catch (e) {
      setError(e.toString());
    }finally{
      setLoading(false);
    }
  }

}