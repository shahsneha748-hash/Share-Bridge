import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin UI widgets', () {
    testWidgets('Ban button shows correct label',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: ElevatedButton(
                  onPressed: null,
                  child: Text('Ban User'),
                ),
              ),
            ),
          );

          expect(find.text('Ban User'), findsOneWidget);
        });

    testWidgets('Status badge displays status text',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Pending'),
                ),
              ),
            ),
          );

          expect(find.text('Pending'), findsOneWidget);
          expect(find.text('Banned'), findsNothing);
        });

    testWidgets('Tapping a button triggers callback',
            (WidgetTester tester) async {
          int tapCount = 0;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ElevatedButton(
                  onPressed: () => tapCount++,
                  child: const Text('Take action'),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Take action'));
          await tester.pump();

          expect(tapCount, 1);
        });
  });
}