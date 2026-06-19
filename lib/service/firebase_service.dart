// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sharebridge/model/saved_items_model.dart';
// import 'package:sharebridge/repo/saved_items_repo.dart';
//
//
//
// class FirebaseService{
//   static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//   static FirebaseFirestore db = FirebaseFirestore.instance;
//   static Reference storageRef = FirebaseStorage.instance.ref();
// }
//
//
// void main() async {
//
//   // we just change the cloudstore reference to fakefirestore references, it will work as same as before but will not change any data in our real database
//   FirebaseService.db = FakeFirebaseFirestore();
//   final SavedItemRepo savedItemRepo = SavedItemRepo();
//
//
//   test('Test Product create', () async {
//     var response = await savedItemRepo
//         .saveItem(
//         SavedItem(name: "productName", price: 125.123)
//     );
//     var data = response.id;
//     expect(data.runtimeType, String);
//   });
//
//   test('Test Product with id', () async {
//     var response = await savedItemRepo.fetchOneSavedItem(id);
//     expect(response.runtimeType, SavedItem);
//   });
//
//   test('Test Product with non id', () async {
//     var response = await savedItemRepo.fetchOneSavedItem("id");
//     expect( null, response);
//   });
// }



