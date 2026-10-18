import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/app/app.dart';

void main() {
  testWidgets('Login page shows brand and continue buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LinkApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
