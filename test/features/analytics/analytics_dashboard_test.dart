import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/analytics/presentation/widgets/analytics_dashboard.dart';

Widget _dashboard({required bool isArabic, ThemeData? theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [AnalyticsDashboard(isArabic: isArabic)],
        ),
      ),
    );

void main() {
  testWidgets('shows empty analytics without invented totals', (tester) async {
    await tester.pumpWidget(_dashboard(isArabic: false));

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Public profile tracking is not connected yet'),
        findsOneWidget);
    expect(find.text('—'), findsNWidgets(4));
    expect(find.text('Visits from your public profile will appear here'),
        findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Anonymous activity only'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Anonymous activity only'), findsOneWidget);
  });

  testWidgets('localizes the dashboard and period controls to Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboard(isArabic: true));

    expect(find.text('الإحصائيات'), findsOneWidget);
    expect(find.text('تتبع الملف العام غير متصل بعد'), findsOneWidget);
    expect(find.text('٢٤ ساعة'), findsOneWidget);
    expect(find.text('زوار مميزون'), findsOneWidget);
  });
}
