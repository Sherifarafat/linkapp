import 'package:flutter/material.dart';

class AnalyticsTopCountries extends StatelessWidget {
  const AnalyticsTopCountries({super.key, required this.isArabic});

  final bool isArabic;

  static const _countries = [
    _CountryShare(
      name: 'United States',
      arabicName: 'أمريكا',
      flag: '🇺🇸',
      percentage: 34,
    ),
    _CountryShare(
      name: 'Egypt',
      arabicName: 'مصر',
      flag: '🇪🇬',
      percentage: 28,
    ),
    _CountryShare(
      name: 'United Kingdom',
      arabicName: 'بريطانيا',
      flag: '🇬🇧',
      percentage: 22,
    ),
    _CountryShare(
      name: 'India',
      arabicName: 'الهند',
      flag: '🇮🇳',
      percentage: 16,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF17181B);
    final secondary = isDark ? Colors.white54 : const Color(0xFF92949B);
    final surface = isDark ? const Color(0xFF19191C) : const Color(0xFFF8F8F9);
    final accent = Theme.of(context).colorScheme.primary;
    final trackColor = isDark ? Colors.white12 : const Color(0xFFE5E5E9);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
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
              Text(
                isArabic ? 'أعلى الدول' : 'Top countries',
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final country in _countries)
                    Expanded(
                      child: _CountryIndicator(
                        country: country,
                        isArabic: isArabic,
                        foreground: foreground,
                        secondary: secondary,
                        accent: accent,
                        trackColor: trackColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryShare {
  const _CountryShare({
    required this.name,
    required this.arabicName,
    required this.flag,
    required this.percentage,
  });

  final String name;
  final String arabicName;
  final String flag;
  final int percentage;
}

class _CountryIndicator extends StatelessWidget {
  const _CountryIndicator({
    required this.country,
    required this.isArabic,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.trackColor,
  });

  final _CountryShare country;
  final bool isArabic;
  final Color foreground;
  final Color secondary;
  final Color accent;
  final Color trackColor;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: country.percentage / 100,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    backgroundColor: trackColor,
                    color: accent,
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2E)
                        : Colors.white,
                  ),
                  child: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 21),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${country.percentage}%',
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isArabic ? country.arabicName : country.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: secondary, fontSize: 8),
          ),
        ],
      );
}
