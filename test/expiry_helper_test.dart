import 'package:flutter_test/flutter_test.dart';
import 'package:sharebridge/utils/expiry_helper.dart';

void main() {
  group('isItemExpired', () {
    test('returns false when category is not food', () {
      final item = {
        'category': 'Clothes',
        'expiryDate': '2020-01-01',
      };
      expect(isItemExpired(item), false);
    });

    test('returns false when category is null', () {
      final item = {
        'expiryDate': '2020-01-01',
      };
      expect(isItemExpired(item), false);
    });

    test('category check is case-insensitive', () {
      final item = {
        'category': 'FOOD',
        'expiryDate': '2020-01-01',
      };
      expect(isItemExpired(item), true);
    });

    test('returns false when expiryDate is null', () {
      final item = {
        'category': 'Food',
        'expiryDate': null,
      };
      expect(isItemExpired(item), false);
    });

    test('returns false when expiryDate is an empty string', () {
      final item = {
        'category': 'Food',
        'expiryDate': '',
      };
      expect(isItemExpired(item), false);
    });

    test('returns false when expiryDate is not a valid date string', () {
      final item = {
        'category': 'Food',
        'expiryDate': 'not-a-date',
      };
      expect(isItemExpired(item), false);
    });

    test('returns true when expiryDate is in the past', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final item = {
        'category': 'Food',
        'expiryDate': yesterday.toIso8601String(),
      };
      expect(isItemExpired(item), true);
    });

    test('returns false when expiryDate is today', () {
      final today = DateTime.now();
      final item = {
        'category': 'Food',
        'expiryDate': today.toIso8601String(),
      };
      expect(isItemExpired(item), false);
    });

    test('returns false when expiryDate is in the future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final item = {
        'category': 'Food',
        'expiryDate': tomorrow.toIso8601String(),
      };
      expect(isItemExpired(item), false);
    });

    test('ignores time component and compares date only', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayLateNight = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        30,
      );
      final item = {
        'category': 'Food',
        'expiryDate': yesterdayLateNight.toIso8601String(),
      };
      expect(isItemExpired(item), true);
    });
  });
}