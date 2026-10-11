import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/app/app.dart';

void main() {
  testWidgets('Home shows the custom navigation bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LinkApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
