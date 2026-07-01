// import 'package:flutter_test/flutter_test.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:sharebridge/model/notification_model.dart';
// import 'package:sharebridge/repo/notification_repo_impl.dart';
//
// void main() {
//   late FakeFirebaseFirestore fakeFirestore;
//   late NotificationRepoImpl repo;
//
//   setUp(() {
//     fakeFirestore = FakeFirebaseFirestore();
//     repo = NotificationRepoImpl(firestore : fakeFirestore);// inject fake Firestore
//   });
//
//   test('addNotification saves a notification', () async {
//     final notification = NotificationModel(
//       id: '',
//       title: 'Hello',
//       body: 'World',
//       receiverId: 'user123',
//       type: 'info',
//       createdAt: DateTime.now(),
//       isRead: false,
//       senderId: '',
//     );
//
//     final result = await repo.addNotification(notification);
//     expect(result, true);
//
//     final saved = await fakeFirestore.collection('notifications').get();
//     expect(saved.docs.length, 1);
//     expect(saved.docs.first['title'], 'Hello');
//   });
//
//   test('getNotificationsByUser returns only that user\'s notifications', () async {
//     await fakeFirestore.collection('notifications').add({
//       'id': '1',
//       'title': 'Msg1',
//       'body': 'Body1',
//       'receiverId': 'userA',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//     await fakeFirestore.collection('notifications').add({
//       'id': '2',
//       'title': 'Msg2',
//       'body': 'Body2',
//       'receiverId': 'userB',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     final list = await repo.getNotificationsByUser('userA');
//     expect(list.length, 1);
//     expect(list.first.receiverId, 'userA');
//   });
//
//   test('getNotificationById returns correct notification', () async {
//     await fakeFirestore.collection('notifications').doc('abc').set({
//       'id': 'abc',
//       'title': 'Test',
//       'body': 'Body',
//       'receiverId': 'user123',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     final found = await repo.getNotificationById('abc');
//     expect(found.title, 'Test');
//   });
//
//   test('editNotification updates values', () async {
//     await fakeFirestore.collection('notifications').doc('abc').set({
//       'id': 'abc',
//       'title': 'Old',
//       'body': 'Body',
//       'receiverId': 'user123',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     final updated = NotificationModel(
//       id: 'abc',
//       title: 'New',
//       body: 'Body',
//       receiverId: 'user123',
//       type: 'info',
//       createdAt: DateTime.now(),
//       isRead: false,
//     );
//
//     await repo.editNotification(updated);
//
//     final doc = await fakeFirestore.collection('notifications').doc('abc').get();
//     expect(doc.data()?['title'], 'New');
//   });
//
//   test('deleteNotification removes notification', () async {
//     await fakeFirestore.collection('notifications').doc('abc').set({
//       'id': 'abc',
//       'title': 'DeleteMe',
//       'receiverId': 'user123',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     await repo.deleteNotification('abc');
//
//     final doc = await fakeFirestore.collection('notifications').doc('abc').get();
//     expect(doc.exists, false);
//   });
//
//   test('markAsRead sets isRead=true', () async {
//     await fakeFirestore.collection('notifications').doc('abc').set({
//       'id': 'abc',
//       'title': 'Unread',
//       'receiverId': 'user123',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     await repo.markAsRead('abc');
//
//     final doc = await fakeFirestore.collection('notifications').doc('abc').get();
//     expect(doc.data()?['isRead'], true);
//   });
//
//   test('getNotificationsByType returns only matching type', () async {
//     await fakeFirestore.collection('notifications').add({
//       'id': '1',
//       'title': 'InfoMsg',
//       'receiverId': 'user123',
//       'type': 'info',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//     await fakeFirestore.collection('notifications').add({
//       'id': '2',
//       'title': 'AlertMsg',
//       'receiverId': 'user123',
//       'type': 'alert',
//       'createdAt': DateTime.now(),
//       'isRead': false,
//     });
//
//     final list = await repo.getNotificationsByType('info');
//     expect(list.length, 1);
//     expect(list.first.type, 'info');
//   });
// }
