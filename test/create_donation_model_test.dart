import 'package:flutter_test/flutter_test.dart';
import 'package:sharebridge/model/create_donation_model.dart';

void main() {
  group('CreateDonationModel.toMap', () {
    test('converts model fields to a map correctly', () {
      final model = CreateDonationModel(
        userId: 'user123',
        donorId: 'donor456',
        donorName: 'Anney',
        location: 'Kathmandu',
        itemName: 'Rice',
        category: 'food',
        condition: 'New',
        portionCount: 3,
      );

      final map = model.toMap();

      expect(map['itemName'], 'Rice');
      expect(map['category'], 'food');
      expect(map['portionCount'], 3);
    });

    test('title falls back to itemName when title is empty', () {
      final model = CreateDonationModel(
        itemName: 'Bread',
        title: '', // left empty on purpose
      );

      final map = model.toMap();

      expect(map['title'], 'Bread');
    });

    test('tags and images default to empty lists', () {
      final model = CreateDonationModel();

      final map = model.toMap();

      expect(map['tags'], []);
      expect(map['images'], []);
    });
  });
}