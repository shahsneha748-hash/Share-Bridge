import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sharebridge/model/user_model.dart';
import 'package:sharebridge/repo/user_repo_impl.dart';
import 'package:sharebridge/service/notification_service.dart';

class FakeNotificationService extends NotificationService {
  @override
  Future<void> requestPermissionOnce() async {

  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late UserRepoImpl repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    repo = UserRepoImpl(auth: mockAuth, firestore: fakeFirestore);
  });

  test('addUser saves the user', () async {
    final user = UserModel(
      uid: 'u1',
      fullName: 'Test',
      email: 't@example.com',
      phone: '9812345678',
      address: 'Kathmandu',
      role: 'user',
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating: 0.0,
      totalDonations: 0,
    );

    await repo.addUser(user);

    final saved = await fakeFirestore.collection('users').doc('u1').get();
    expect(saved.exists, true);
    expect(saved['fullName'], 'Test');
  });

  test('getUserById returns user', () async {
    await fakeFirestore.collection('users').doc('abc').set({
      'uid': 'abc',
      'fullName': 'Cheten',
      'email': 'cheten@example.com',
    });

    final found = await repo.getUserById('abc');
    expect(found.fullName, 'Cheten');
  });

  test('deleteUser removes the user', () async {
    await fakeFirestore.collection('users').doc('del').set({'uid': 'del'});
    await repo.deleteUser('del');
    final doc = await fakeFirestore.collection('users').doc('del').get();
    expect(doc.exists, false);
  });

  test('signup returns a uid (not null)', () async {
    final userId = await repo.signup('signup@example.com', 'password');
    expect(userId, isNotNull);
  });

  test('logout completes', () async {
    expect(repo.logout(), completes);
  });

  test('forgetpassword completes', () async {
    expect(repo.forgetpassword('reset@example.com'), completes);
  });

  test('getReceiverName returns name', () async {
    await fakeFirestore.collection('users').doc('r1').set({'name': 'Receiver'});
    final name = await repo.getReceiverName('r1');
    expect(name, 'Receiver');
  });

  test('getProfilePicture returns url', () async {
    await fakeFirestore.collection('users').doc('s1').set({'profilePicture': 'pic.png'});
    final pic = await repo.getProfilePicture('s1');
    expect(pic, 'pic.png');
  });

  test('editProfile updates user data', () async {
    await fakeFirestore.collection('users').doc('e1').set({
      'uid': 'e1',
      'fullName': 'Old Name',
      'email': 'old@example.com',
    });

    final updatedUser = UserModel(
      uid: 'e1',
      fullName: 'New Name',
      email: 'new@example.com',
      phone: '9811111111',
      address: 'Kathmandu',
      role: 'user',
      isVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating: 4.5,
      totalDonations: 10,
    );

    await repo.editProfile(updatedUser);

    final doc = await fakeFirestore.collection('users').doc('e1').get();
    expect(doc['fullName'], 'New Name');
    expect(doc['email'], 'new@example.com');
  });

  test('getAllUsers returns list', () async {
    await fakeFirestore.collection('users').doc('u1').set({'uid': 'u1', 'fullName': 'User1'});
    await fakeFirestore.collection('users').doc('u2').set({'uid': 'u2', 'fullName': 'User2'});

    final users = await repo.getAllUsers();
    expect(users.length, 2);
  });
}
