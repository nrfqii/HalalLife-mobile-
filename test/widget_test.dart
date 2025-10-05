// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:halallife/main.dart';

void main() {
  testWidgets('App shows FloatingActionButton on home screen', (
    WidgetTester tester,
  ) async {
    // Pump the app wrapped with ProviderScope (Riverpod)
    await tester.pumpWidget(const ProviderScope(child: HalalLifeApp()));
    await tester.pumpAndSettle();

    // The main layout shows a FloatingActionButton with Icons.add on the home screen
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
