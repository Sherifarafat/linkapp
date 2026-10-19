import 'package:flutter/material.dart';

class AnalyticsTrafficTime extends StatelessWidget {
  const AnalyticsTrafficTime({super.key, required this.isArabic});

  final bool isArabic;

  static const _activity = [0.22, 0.36, 0.44, 0.31, 0.64, 0.95];
  static const _hours = ['6 AM', '9 AM', '12 PM', '3 PM', '6 PM', '9 PM'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF17181B);
    final secondary = isDark ? Colors.white54 : const Color(0xFF92949B);
    final surface = isDark ? const Color(0xFF19191C) : const Color(0xFFF8F8F9);
    final accent = Theme.of(context).colorScheme.primary;
    final mutedBar = isDark ? Colors.white24 : const Color(0xFFD9DCE5);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 88),
      sliver: SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: secondary),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      isArabic ? 'وقت ذروة الزيارات' : 'Peak traffic time',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isArabic ? 'الأعلى' : 'Peak',
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                isArabic ? '٧–٩ مساءً' : '7–9 PM',
                style: TextStyle(
                  color: foreground,
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isArabic
                    ? 'الفترة الأكثر نشاطًا لدى جمهورك'
                    : 'Your audience is most active',
                style: TextStyle(color: secondary, fontSize: 10),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 82,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < _activity.length; index++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: _activity[index],
                                    widthFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: index == _activity.length - 1
                                            ? accent
                                            : mutedBar,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isArabic
                                    ? _arabicHours[index]
                                    : _hours[index],
                                maxLines: 1,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _arabicHours = [
    '٦ ص',
    '٩ ص',
    '١٢ م',
    '٣ م',
    '٦ م',
    '٩ م',
  ];
}
