import 'package:flutter/material.dart';

import '../../../../app/theme/app_shadows.dart';

enum _AnalyticsPeriod { day, week, month, quarter, custom }

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  _AnalyticsPeriod _period = _AnalyticsPeriod.week;
  DateTimeRange? _customRange;

  String _text(String english, String arabic) =>
      widget.isArabic ? arabic : english;

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _customRange,
      helpText: _text('Choose analytics range', 'اختار فترة الإحصائيات'),
    );
    if (range == null || !mounted) return;
    setState(() {
      _customRange = range;
      _period = _AnalyticsPeriod.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final periods = [
      (_AnalyticsPeriod.day, _text('24 hours', '٢٤ ساعة')),
      (_AnalyticsPeriod.week, _text('7 days', '٧ أيام')),
      (_AnalyticsPeriod.month, _text('30 days', '٣٠ يوم')),
      (_AnalyticsPeriod.quarter, _text('90 days', '٩٠ يوم')),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            _text('Analytics', 'الإحصائيات'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _text(
              'Understand how people find and use your profile.',
              'تابع الناس بتوصل لملفك وبتتفاعل معاه إزاي.',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 18),
          _TrackingSetupCard(isArabic: widget.isArabic),
          const SizedBox(height: 24),
          _SectionHeading(
            title: _text('Overview', 'نظرة عامة'),
            trailing: _text('No data yet', 'لا توجد بيانات بعد'),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.62,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                icon: Icons.visibility_outlined,
                title: _text('Profile views', 'مشاهدات الملف'),
                value: '—',
                detail: _text('Total views', 'إجمالي المشاهدات'),
              ),
              _MetricCard(
                icon: Icons.person_outline_rounded,
                title: _text('Unique visitors', 'زوار مميزون'),
                value: '—',
                detail: _text('Estimated', 'تقديري'),
              ),
              _MetricCard(
                icon: Icons.ads_click_rounded,
                title: _text('Link clicks', 'نقرات الروابط'),
                value: '—',
                detail: _text('All profile links', 'كل روابط الملف'),
              ),
              _MetricCard(
                icon: Icons.favorite_border_rounded,
                title: _text('Engagement', 'التفاعل'),
                value: '—',
                detail: _text('Engagement rate', 'معدل التفاعل'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeading(
            title: _text('Profile views', 'مشاهدات الملف'),
            trailing: _text('Previous period: —', 'الفترة السابقة: —'),
          ),
          const SizedBox(height: 12),
          _AnalyticsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final period in periods)
                      _PeriodChip(
                        label: period.$2,
                        selected: _period == period.$1,
                        onTap: () => setState(() => _period = period.$1),
                      ),
                    _PeriodChip(
                      label: _customRange == null
                          ? _text('Custom', 'مخصص')
                          : '${_customRange!.start.month}/${_customRange!.start.day} – ${_customRange!.end.month}/${_customRange!.end.day}',
                      selected: _period == _AnalyticsPeriod.custom,
                      onTap: _selectCustomRange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 164,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _EmptyChartPainter(
                      color: colors.outlineVariant.withValues(
                        alpha: isDark ? .6 : .75,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _text(
                            'Visits from your public profile will appear here',
                            'مشاهدات ملفك العام هتظهر هنا',
                          ),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeading(title: _text('Audience', 'الجمهور')),
          const SizedBox(height: 12),
          _AnalyticsPlaceholderCard(
            icon: Icons.devices_rounded,
            title: _text('Devices and browsers', 'الأجهزة والمتصفحات'),
            detail: _text(
              'Mobile, desktop, operating system, and browser breakdowns will appear when tracking is connected.',
              'تفاصيل الموبايل والكمبيوتر ونظام التشغيل والمتصفح هتظهر بعد ربط التتبع.',
            ),
          ),
          const SizedBox(height: 10),
          _AnalyticsPlaceholderCard(
            icon: Icons.public_rounded,
            title: _text('Locations', 'المواقع الجغرافية'),
            detail: _text(
              'Country estimates will be shown only when they are available. City information may be approximate.',
              'هنعرض تقدير الدولة عند توفره، ومعلومات المدينة ممكن تكون تقريبية.',
            ),
          ),
          const SizedBox(height: 10),
          _AnalyticsPlaceholderCard(
            icon: Icons.route_rounded,
            title: _text('Traffic sources', 'مصادر الزيارات'),
            detail: _text(
              'Direct, referral, campaign, and tracked QR visits will be separated here.',
              'هنا هتظهر الزيارات المباشرة والإحالات والحملات وQR المتتبع.',
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeading(title: _text('Performance', 'الأداء')),
          const SizedBox(height: 12),
          _AnalyticsPlaceholderCard(
            icon: Icons.link_rounded,
            title: _text('Link performance', 'أداء الروابط'),
            detail: _text(
              'Clicks for each profile link and click-through rates will appear here.',
              'هنا هتظهر نقرات كل رابط ومعدل التحويل للنقر.',
            ),
          ),
          const SizedBox(height: 10),
          _AnalyticsPlaceholderCard(
            icon: Icons.touch_app_outlined,
            title: _text('Engagement', 'التفاعل'),
            detail: _text(
              'Profile shares and contact, email, and messaging link clicks will appear here.',
              'هنا هتظهر مشاركات الملف ونقرات الاتصال والبريد والرسائل.',
            ),
          ),
          const SizedBox(height: 10),
          _AnalyticsPlaceholderCard(
            icon: Icons.calendar_month_outlined,
            title: _text('Visit activity', 'نشاط الزيارات'),
            detail: _text(
              'Activity by day and hour will appear here after enough visit data is collected.',
              'النشاط حسب اليوم والساعة هيظهر بعد جمع بيانات زيارات كافية.',
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeading(title: _text('Recent visitors', 'الزوار مؤخرًا')),
          const SizedBox(height: 12),
          _AnalyticsPlaceholderCard(
            icon: Icons.visibility_outlined,
            title: _text('Anonymous activity only', 'نشاط مجهول فقط'),
            detail: _text(
              'Visitors are not identified by name. Approximate country, device, and browser may appear when available.',
              'مش هنعرض هوية الزوار. ممكن يظهر تقدير الدولة والجهاز والمتصفح عند توفرهم.',
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _TrackingSetupCard extends StatelessWidget {
  const _TrackingSetupCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            colors.primary.withValues(alpha: isDark ? .24 : .11),
            colors.primary.withValues(alpha: isDark ? .10 : .04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'تتبع الملف العام غير متصل بعد'
                      : 'Public profile tracking is not connected yet',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'مش هنعرض أرقام غير حقيقية. لازم ربط صفحة الملف العامة والباك إند الأول.'
                      : 'No analytics are fabricated. Connect the public profile and backend to start collecting data.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _AnalyticsCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary.withValues(alpha: .12) : colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.of(context).soft,
      ),
      child: child,
    );
  }
}

class _AnalyticsPlaceholderCard extends StatelessWidget {
  const _AnalyticsPlaceholderCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _AnalyticsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartPainter extends CustomPainter {
  const _EmptyChartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = size.height * (index + 1) / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmptyChartPainter oldDelegate) =>
      oldDelegate.color != color;
}
