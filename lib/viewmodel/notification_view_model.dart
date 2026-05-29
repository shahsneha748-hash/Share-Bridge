import 'package:flutter/material.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/repo/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {            // The NotificationViewModel class extends ChangeNotifier class so that it can call notifyListeners() method to notify UI widgets (i.e the view layer) when it's internal states changes or it's data changes. Then the view layers is reactive accordingly to these changes.
  final NotificationRepo _notificationRepo;

  NotificationViewModel({required NotificationRepo notificationRepo
  }) : _notificationRepo = notificationRepo;

  String? _error = "";
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  List<NotificationModel>? _notifications;
  List<NotificationModel>? get notifications => _notifications;

  NotificationModel? _selectedNotification;
  NotificationModel? get selectedNotification => _selectedNotification;

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // CREATE
  Future<bool> addNotification(NotificationModel notification) async {
    setLoading(true);
    setError(null);
    try {
      await _notificationRepo.addNotification(notification);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // DELETE
  Future<bool> deleteNotification(String id) async {
    setLoading(true);
    setError(null);
    try{
      await _notificationRepo.deleteNotification(id);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // UPDATE (mark as read)
  Future<bool> markAsRead(String id) async {
    setLoading(true);
    setError(null);
    try{
      await _notificationRepo.markAsRead(id);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // READ (all by user)
  Future<void> getNotificationsByUser(String user) async {
    setLoading(true);
    setError(null);
    try {
      _notifications = await _notificationRepo.getNotificationsByUser(user);
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // READ (by type)
  Future<void> getNotificationsByType(String type) async {
    setLoading(true);
    setError(null);
    try {
      _notifications = await _notificationRepo.getNotificationsByType(type);
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // READ (single notification)
  Future<void> getNotificationById(String id) async {
    setLoading(true);
    setError(null);
    try {
      _selectedNotification = await _notificationRepo.getNotificationById(id);
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // UPDATE (edit notification)
  Future<bool> editNotification(NotificationModel notification) async {
    setLoading(true);
    setError(null);
    try {
      await _notificationRepo.editNotification(notification);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
