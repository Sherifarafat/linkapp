import 'package:flutter/material.dart';

class AnalyticsDeviceBreakdown extends StatelessWidget {
  const AnalyticsDeviceBreakdown({super.key, required this.isArabic});

  final bool isArabic;

  static const _devices = [
    _DeviceShare(
      label: 'Android',
      arabicLabel: 'أندرويد',
      percentage: 58,
      color: Color(0xFFAA82F5),
      icon: Icons.phone_android_rounded,
    ),
    _DeviceShare(
      label: 'iOS',
      arabicLabel: 'iOS',
      percentage: 27,
      color: Color(0xFFF4CC12),
      icon: Icons.phone_iphone_rounded,
    ),
    _DeviceShare(
      label: 'Desktop',
      arabicLabel: 'كمبيوتر',
      percentage: 15,
      color: Color(0xFF35BCEB),
      icon: Icons.desktop_windows_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF17181B);
    final secondary = isDark ? Colors.white54 : const Color(0xFF92949B);
    final surface = isDark ? const Color(0xFF19191C) : const Color(0xFFF8F8F9);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'الزوار حسب الجهاز' : 'Visitors by device',
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 8,
                child: CustomPaint(
                  painter: _DeviceSharesPainter(_devices),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var index = 0; index < _devices.length; index++) ...[
                    if (index > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _DeviceLegend(
                        device: _devices[index],
                        isArabic: isArabic,
                        foreground: foreground,
                        secondary: secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceSharesPainter extends CustomPainter {
  const _DeviceSharesPainter(this.devices);

  final List<_DeviceShare> devices;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 3.0;
    final availableWidth = size.width - gap * (devices.length - 1);
    var left = 0.0;

    for (final device in devices) {
      final segmentWidth = availableWidth * device.percentage / 100;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, segmentWidth, size.height),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = device.color);
      left += segmentWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DeviceSharesPainter oldDelegate) =>
      oldDelegate.devices != devices;
}

class _DeviceShare {
  const _DeviceShare({
    required this.label,
    required this.arabicLabel,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String label;
  final String arabicLabel;
  final int percentage;
  final Color color;
  final IconData icon;
}

class _DeviceLegend extends StatelessWidget {
  const _DeviceLegend({
    required this.device,
    required this.isArabic,
    required this.foreground,
    required this.secondary,
  });

  final _DeviceShare device;
  final bool isArabic;
  final Color foreground;
  final Color secondary;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(device.icon, size: 13, color: secondary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  isArabic ? device.arabicLabel : device.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${device.percentage}%',
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}
