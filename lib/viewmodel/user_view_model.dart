import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/repo/notification_repo.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class UserViewModel extends ChangeNotifier {
  String? _storedEmail;
  String? _storedPassword;

  String? get storedEmail => _storedEmail;
  String? get storedPassword => _storedPassword;

  void setCredentials(String email, String password) {
    _storedEmail = email;
    _storedPassword = password;
    notifyListeners();
  }

  final UserRepo _userRepo;
  final NotificationRepo _notificationRepo;

  UserViewModel({
    required UserRepo userRepo,
    required NotificationRepo notificationRepo,
  })  : _userRepo = userRepo,
        _notificationRepo = notificationRepo;

  String? _error = "";
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  UserModel? _user;
  UserModel? get user => _user;

  List<UserModel>? _allUsers;
  List<UserModel>? get allUsers => _allUsers;

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<String> login(String email, String password) async {
    final id = await _userRepo.login(email, password);
    if (id.isNotEmpty) {
      await _notificationRepo.saveUserFcmToken();
    }
    return id;
  }

  Future<String> signup(String email, String password) async {
    final id = await _userRepo.signup(email, password);
    if (id.isNotEmpty) {
      await _notificationRepo.saveUserFcmToken();
    }
    return id;
  }

  Future<bool> logout() async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.logout();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> forgetpassword(String email) async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.forgetpassword(email);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addUser(UserModel userModel) async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.addUser(userModel);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteUser(String id) async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.deleteUser(id);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> getAllUsers() async {
    setLoading(true);
    setError(null);
    try {
      _allUsers = await _userRepo.getAllUsers();
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> getUserById(String id) async {
    setLoading(true);
    setError(null);
    try {
      _user = await _userRepo.getUserById(id);
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> editProfile(UserModel userModel) async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.editProfile(userModel);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
  Future<String> getReceiverName(String receiverId) async {
    return await _userRepo.getReceiverName(receiverId);
  }

}


// Note: Sabai get ma bool data type ani aru ma bool datatype use garnu parcha.