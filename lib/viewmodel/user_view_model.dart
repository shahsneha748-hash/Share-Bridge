import 'package:flutter/material.dart';
import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo.dart';

  class UserViewModel extends ChangeNotifier {              // Yo ViewModel ko lagi we use StateManagement ani yo StateManagement ko lagi we use provider. State bhaneko data ho tyo jun bela pani change hunu sakcha. Ra tyo change bhako data lai manage garna we use provider        // ChangeNotifier material.dart bata import garneh first.       //DataManagement ko lagi we use provider.
  final UserRepo _userRepo;                                 // userRepo use garna instance banakp

  UserViewModel({                            // userviewmodel ko constructor banako
  required UserRepo userRepo
  }) : _userRepo = userRepo;                // constructor call huneh bitikai k call hunu paryo bhanneh yo semi colon pachi. Use of semi colon is yo constructor call huneh bitikai yo constructor ma pass gareko value yah mathi ko variable ma assign garnu paryo

  String? _error = "";               // app ma changes huneh data sabai ViewModel bata manage huncha so euta bhaneko error ko message 1st.          // kun kun data change huncha tyo sabai ko variable banau parcha so error ko variable baanko     // _error (_ this understore in front of error identifies it is private.)
  String? get error => _error;       // jj ko value change huncha tesko tesko variable banauneh. Eg: error, loading, user, allUsers etc.

  bool _loading = false;             // arko loading ko state manage garnu parcha
  bool get loading => _loading;

  UserModel? _user;                  // arko UserModel ko data change hunu sakcha so banako yesko private variable named _user. (Note variable ko name j pani rakhnu payo)
  UserModel? get user => _user;

  List<UserModel>? _allUsers;        // arko list<UserModel> ko data change hunu sakcha so banako
  List<UserModel>? get allUsers => _allUsers;

  // Note: to make getter follow this method:     datatype get getter ko name => and ani k get garnu ateko
  // changes bhairakneh data haru handle garnu lai banako hamileh yo private variable. Tespachi tyo private variable haru lai (view layer) screen bata access garnu lai tesko getter banako hamileh.
  // view ma kk change huncha tesko private variable banako

  // hamileh repo ma banako functions haru bata changes huneh data k k hunu sakcha? So changes huneh data are error, loading, UserModel, list<UserModel>. So yeni haru ko variable banaunu parcha.
  // Yo hamileh banako variable ma sabai _ underscore cha which indicates it's a private variable. So yo private variables aru class bata access garnu lai getter banaunu parcha first.

  void setError(String? error){                  // setter banako ani tala notifilistner ma notify gareko by making notify listener
  _error = error;
  notifyListeners();
  }

  void setLoading(bool value){
  _loading = value;
  notifyListeners();        // data change bhaye pachi garnu lai use gareko notifyListeners();       //here we notify the widgets (the view layer)
  }

  Future<bool> login (String email, String password) async {
    setLoading(true);
    setError(null);
    try{
      await _userRepo.login(email, password);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<String> register (String email, String password) async {              // jaba register button click garcha register leh 2 things call garcha authentication and firestore so that's y it returns string
  final id = await _userRepo.login(email, password);
  return id;
  }

  Future<bool> logout() async {
    setLoading(true);
    setError(null);
    try{
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
  try{
  await _userRepo.forgetpassword(email);
  return true;
  } on Exception catch (e) {
  setError(e.toString());
  return false;
  } finally {
  setLoading(false);
  }
  }

  // CREATE
  Future<bool> addUser(UserModel userModel) async {
  setLoading(true);
  setError(null);
  try{
  await _userRepo.addUser(userModel);
  return true;
  } on Exception catch (e) {
  setError(e.toString());
  return false;
  } finally {
  setLoading(false);
  }
  }

  // DELETE
  Future<bool> deleteUser(String id) async {
  setLoading(true);
  setError(null);
  try{
  await _userRepo.deleteUser(id);
  return true;
  } on Exception catch (e) {
  setError(e.toString());
  return false;
  } finally {
  setLoading(false);
  }
  }

  // READ (all by users)
  Future<void> getAllUsers() async {
    setLoading(true);
    setError(null);
    try {
      _allUsers = await _userRepo.getAllUsers();
    } on Exception catch (e) {
      setError(e.toString());
    }finally{
      setLoading(false);
    }
  }

  // READ (single user)
  Future<void> getUserById(String id) async {
    setLoading(true);
    setError(null);
    try {
      _user= await _userRepo.getUserById(id);
    } on Exception catch (e) {
      setError(e.toString());
    }finally{
      setLoading(false);
    }
  }

  // UPDATE (edit profile)
  Future<bool> editProfile(UserModel userModel) async {
  setLoading(true);
  setError(null);
  try{
  await _userRepo.editProfile(userModel);
  return true;
  } on Exception catch (e) {
  setError(e.toString());
  return false;
  } finally {
  setLoading(false);
  }

  }

}


// Note: Sabai get ma bool data type ani aru ma bool datatype use garnu parcha.