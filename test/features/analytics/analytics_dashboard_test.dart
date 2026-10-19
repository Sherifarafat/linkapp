import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/features/analytics/presentation/widgets/analytics_date_selector.dart';
import 'package:link/features/analytics/presentation/widgets/analytics_sales_card.dart';

Widget _dateSelector({required bool isArabic, ThemeData? theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            AnalyticsDateSelector(isArabic: isArabic),
            AnalyticsSalesCard(isArabic: isArabic),
          ],
        ),
      ),
    );

String _monthLabel(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('analytics-month'))).data!;

String _selectedDay(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('selected-day'))).data!;

void main() {
  testWidgets('starts with a month bar and a five-day date strip', (
    tester,
  ) async {
    await tester.pumpWidget(_dateSelector(isArabic: false));

    expect(find.byKey(const ValueKey('analytics-month')), findsOneWidget);
    expect(find.byKey(const ValueKey('previous-month')), findsOneWidget);
    expect(find.byKey(const ValueKey('next-month')), findsOneWidget);
    expect(find.byKey(const ValueKey('previous-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('next-day')), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-day')), findsOneWidget);
    expect(find.byType(AnalyticsDateSelector), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'Mon|Tue|Wed|Thu|Fri|Sat|Sun')),
      findsNWidgets(5),
    );
    expect(find.text('18,420'), findsOneWidget);
    expect(find.text('Total views'), findsOneWidget);
    expect(find.text('Total clicks'), findsOneWidget);
  });

  testWidgets('month and day arrows update the selected date', (tester) async {
    await tester.pumpWidget(_dateSelector(isArabic: false));
    final initialMonth = _monthLabel(tester);
    final initialDay = _selectedDay(tester);

    await tester.tap(find.byKey(const ValueKey('next-month')));
    await tester.pumpAndSettle();
    expect(_monthLabel(tester), isNot(initialMonth));
    final dayAfterMonthChange = _selectedDay(tester);

    await tester.tap(find.byKey(const ValueKey('next-day')));
    await tester.pumpAndSettle();
    expect(_selectedDay(tester), isNot(dayAfterMonthChange));
  });

  testWidgets('localizes month and weekday names to Arabic', (tester) async {
    await tester.pumpWidget(_dateSelector(isArabic: true));

    expect(_monthLabel(tester), contains(DateTime.now().year.toString()));
    expect(
      find.textContaining(
        RegExp(r'الإثنين|الثلاثاء|الأربعاء|الخميس|الجمعة|السبت|الأحد'),
      ),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('إجمالي المشاهدات'), findsOneWidget);
    expect(find.text('إجمالي النقرات'), findsOneWidget);
  });
}
