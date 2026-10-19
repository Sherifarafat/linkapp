import 'package:flutter/material.dart';


class AnalyticsSalesCard extends StatelessWidget {
  const AnalyticsSalesCard({super.key, required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF17181B);
    final secondary = isDark ? Colors.white54 : const Color(0xFF92949B);
    final surface = isDark ? const Color(0xFF19191C) : const Color(0xFFF8F8F9);
    final accent = Theme.of(context).colorScheme.primary;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '18,420',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5FAF3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_upward_rounded,
                            size: 9, color: Color(0xFF20BA83)),
                        Text(
                          '12.5%',
                          style: TextStyle(
                            color: Color(0xFF20BA83),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 102,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SalesChartPainter(
                    lineColor: accent,
                    fillColor: accent.withValues(alpha: isDark ? 0.24 : 0.12),
                    labelColor: secondary,
                    tooltipColor: isDark
                        ? const Color(0xFF2B2D34)
                        : Colors.white,
                    isArabic: isArabic,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              _MetricRow(
                icon: Icons.person_outline_rounded,
                label: isArabic ? 'إجمالي المشاهدات' : 'Total views',
                value: '384',
                foreground: foreground,
                secondary: secondary,
              ),
              const SizedBox(height: 9),
              _MetricRow(
                icon: Icons.ads_click_rounded,
                label: isArabic ? 'إجمالي النقرات' : 'Total clicks',
                value: '126',
                foreground: foreground,
                secondary: secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.foreground,
    required this.secondary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color foreground;
  final Color secondary;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: secondary, fontSize: 11),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _SalesChartPainter extends CustomPainter {
  const _SalesChartPainter({
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
    required this.tooltipColor,
    required this.isArabic,
  });

  final Color lineColor;
  final Color fillColor;
  final Color labelColor;
  final Color tooltipColor;
  final bool isArabic;

  static const _values = [
    0.69,
    0.69,
    0.47,
    0.55,
    0.52,
    0.34,
    0.45,
    0.51,
    0.38,
    0.31,
    0.62,
    0.78,
    0.66,
    0.51,
    0.40,
    0.48,
    0.58,
    0.49,
    0.39,
    0.48,
    0.53,
    0.45,
    0.39,
    0.43,
    0.35,
    0.40,
    0.29,
    0.23,
    0.17,
    0.10,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const plotTop = 15.0;
    const plotBottom = 66.0;
    final points = List<Offset>.generate(
      _values.length,
      (index) => Offset(
        size.width * index / (_values.length - 1),
        plotTop + (plotBottom - plotTop) * _values[index],
      ),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(size.width, plotBottom + 4)
      ..lineTo(0, plotBottom + 4)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(
        Rect.fromLTWH(0, plotTop, size.width, plotBottom - plotTop + 4),
      );
    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final marker = points[12];
    final tooltipText = isArabic ? '١٤ يونيو  ١٬٨٥٠' : 'Jun 14  ·  1,850';
    final textPainter = TextPainter(
      text: TextSpan(
        text: tooltipText,
        style: TextStyle(
          color: labelColor,
          fontSize: 7,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(marker.dx, marker.dy - 11),
        width: textPainter.width + 8,
        height: textPainter.height + 5,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(tooltipRect, Paint()..color = tooltipColor);
    textPainter.paint(
      canvas,
      Offset(tooltipRect.left + 4, tooltipRect.top + 2),
    );
    canvas.drawCircle(marker, 2.5, Paint()..color = lineColor);
    canvas.drawCircle(points.last, 2.5, Paint()..color = lineColor);

    _drawLabel(canvas, isArabic ? '١ يونيو' : 'JUN 1', 0, size.width);
    _drawLabel(
      canvas,
      isArabic ? '١٤ يونيو' : 'JUN 14',
      size.width / 2,
      size.width,
      centered: true,
    );
    _drawLabel(
      canvas,
      isArabic ? '٣٠ يونيو' : 'JUN 30',
      size.width,
      size.width,
      alignRight: true,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    double x,
    double width, {
    bool centered = false,
    bool alignRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: labelColor,
          fontSize: 7,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    final left = centered
        ? x - painter.width / 2
        : alignRight
            ? width - painter.width
            : x;
    painter.paint(canvas, Offset(left, 78));
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) =>
      lineColor != oldDelegate.lineColor ||
      fillColor != oldDelegate.fillColor ||
      labelColor != oldDelegate.labelColor ||
      tooltipColor != oldDelegate.tooltipColor ||
      isArabic != oldDelegate.isArabic;
}
