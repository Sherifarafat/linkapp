import 'package:flutter/material.dart';

class AnalyticsDateSelector extends StatefulWidget {
  const AnalyticsDateSelector({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<AnalyticsDateSelector> createState() => _AnalyticsDateSelectorState();
}

class _AnalyticsDateSelectorState extends State<AnalyticsDateSelector> {
  late DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  static const _englishMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  void _moveMonth(int amount) {
    final nextMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + amount,
    );
    final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    setState(() {
      _selectedDate = DateTime(
        nextMonth.year,
        nextMonth.month,
        _selectedDate.day > lastDay ? lastDay : _selectedDate.day,
      );
    });
  }

  void _moveDay(int amount) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: amount)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF19191C) : Colors.white;
    final secondaryCardColor =
        isDark ? const Color(0xFF232327) : const Color(0xFFF0F0F2);
    final selectedColor =
        isDark ? const Color(0xFF34343A) : const Color(0xFFE4E4E9);
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final monthName = (widget.isArabic ? _arabicMonths : _englishMonths)[
        _selectedDate.month - 1];
    final monthLabel = '$monthName ${_selectedDate.year}';

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _DateArrowButton(
                    key: const ValueKey('previous-month'),
                    icon: Icons.chevron_left_rounded,
                    color: secondaryCardColor,
                    foreground: secondaryText,
                    onPressed: () => _moveMonth(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        monthLabel,
                        key: const ValueKey('analytics-month'),
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  _DateArrowButton(
                    key: const ValueKey('next-month'),
                    icon: Icons.chevron_right_rounded,
                    color: secondaryCardColor,
                    foreground: secondaryText,
                    onPressed: () => _moveMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              decoration: BoxDecoration(
                color: secondaryCardColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  _DateArrowButton(
                    key: const ValueKey('previous-day'),
                    icon: Icons.chevron_left_rounded,
                    color: cardColor,
                    foreground: secondaryText,
                    onPressed: () => _moveDay(-1),
                    compact: true,
                  ),
                  for (var offset = -2; offset <= 2; offset++)
                    Expanded(
                      child: _DayButton(
                        date: _selectedDate.add(Duration(days: offset)),
                        isSelected: offset == 0,
                        isArabic: widget.isArabic,
                        selectedColor: selectedColor,
                        foreground: colors.onSurface,
                        secondaryText: secondaryText,
                        onPressed: () => setState(
                          () => _selectedDate = DateUtils.dateOnly(
                            _selectedDate.add(Duration(days: offset)),
                          ),
                        ),
                      ),
                    ),
                  _DateArrowButton(
                    key: const ValueKey('next-day'),
                    icon: Icons.chevron_right_rounded,
                    color: cardColor,
                    foreground: secondaryText,
                    onPressed: () => _moveDay(1),
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.date,
    required this.isSelected,
    required this.isArabic,
    required this.selectedColor,
    required this.foreground,
    required this.secondaryText,
    required this.onPressed,
  });

  final DateTime date;
  final bool isSelected;
  final bool isArabic;
  final Color selectedColor;
  final Color foreground;
  final Color secondaryText;
  final VoidCallback onPressed;

  static const _englishWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _arabicWeekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    final weekday =
        (isArabic ? _arabicWeekdays : _englishWeekdays)[date.weekday - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            height: 54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekday,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? foreground : secondaryText,
                    fontSize: isArabic ? 9 : 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date.day.toString().padLeft(2, '0'),
                  key: isSelected ? const ValueKey('selected-day') : null,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateArrowButton extends StatelessWidget {
  const _DateArrowButton({
    super.key,
    required this.icon,
    required this.color,
    required this.foreground,
    required this.onPressed,
    this.compact = false,
  });

  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        borderRadius: BorderRadius.circular(compact ? 7 : 8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(compact ? 7 : 8),
          child: SizedBox(
            width: compact ? 23 : 21,
            height: compact ? 25 : 24,
            child: Icon(icon, size: 18, color: foreground),
          ),
        ),
      );
}
