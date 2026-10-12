import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/widgets/app_alert.dart';

const _profileImageUrl =
    'https://i.pinimg.com/736x/cf/c0/b5/cfc0b5f17ed198ba268925516db2e951.jpg';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showCode = true;
  bool _didScanCode = false;
  MobileScannerController? _scannerController;
  final _shareKey = GlobalKey();

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _showScanner() {
    _didScanCode = false;
    _scannerController ??= MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
    setState(() => _showCode = false);
  }

  void _showMyCode() {
    setState(() => _showCode = true);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_didScanCode) return;
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (value == null) return;
    _didScanCode = true;
    _scannerController?.stop();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    AppAlert.show(
      context,
      title: isArabic ? 'تم مسح الرمز' : 'Code scanned',
      message: value,
    );
  }

  Future<void> _shareProfile() async {
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final rect = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(100, 100, 100, 100);

    await SharePlus.instance.share(
      ShareParams(
        text: 'https://link.app/sherifarafat2000',
        subject: 'Sherif Arafat profile',
        sharePositionOrigin: rect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(
            color: colors.surface.withValues(alpha: 0.94),
            child: _showCode
                ? _buildMyCode(context, colors, appColors)
                : _buildScanner(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMyCode(
    BuildContext context,
    ColorScheme colors,
    AppColors appColors,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProfileCircleButton(
                  icon: Icons.close_rounded,
                  label: isArabic ? 'إغلاق' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                _ProfileCircleButton(
                  key: _shareKey,
                  icon: Icons.ios_share_rounded,
                  label: isArabic ? 'مشاركة الملف الشخصي' : 'Share profile',
                  onPressed: _shareProfile,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Column(
              children: [
                ClipOval(
                  child: Image.network(
                    _profileImageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: appColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sherif Arafat',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@sherifarafat2000',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: colors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: const _ProfileQrCode(),
                ),
              ),
            ),
            _ProfileModeSwitch(
              showCode: true,
              onChanged: (value) => value ? _showMyCode() : _showScanner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
          errorBuilder: (context, error) => ColoredBox(
            color: const Color(0xFF181818),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  isArabic
                      ? 'يلزم السماح باستخدام الكاميرا لمسح الرمز.'
                      : 'Camera access is needed to scan a code.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: .34),
                  ],
                  stops: const [0, .48, 1],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 20,
                child: _ProfileCircleButton(
                  icon: Icons.close_rounded,
                  label: isArabic ? 'إغلاق' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 18,
                right: 20,
                child: _ProfileCircleButton(
                  icon: Icons.flash_on_rounded,
                  label: isArabic ? 'تشغيل الفلاش' : 'Toggle flash',
                  onPressed: () => _scannerController?.toggleTorch(),
                ),
              ),
              Center(
                child: Container(
                  width: size.width * .76,
                  height: size.height * .40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(34),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Center(
                  child: _ProfileModeSwitch(
                    showCode: false,
                    scanAppearance: true,
                    onChanged: (value) =>
                        value ? _showMyCode() : _showScanner(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  const _ProfileCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ).copyWith(boxShadow: AppShadows.of(context).soft),
        child: Material(
          color: colors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, size: 23, color: colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileModeSwitch extends StatelessWidget {
  const _ProfileModeSwitch({
    required this.showCode,
    required this.onChanged,
    this.scanAppearance = false,
  });

  final bool showCode;
  final ValueChanged<bool> onChanged;
  final bool scanAppearance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      height: 54,
      width: 250,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scanAppearance
            ? Colors.black.withValues(alpha: .22)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
        border: scanAppearance
            ? Border.all(color: Colors.white.withValues(alpha: .12))
            : null,
      ),
      child: Row(
        children: [
          _ModeOption(
            label: isArabic ? 'مسح' : 'Scan',
            selected: !showCode,
            scanAppearance: scanAppearance,
            onTap: () => onChanged(false),
          ),
          _ModeOption(
            label: isArabic ? 'رمزي' : 'My code',
            selected: showCode,
            scanAppearance: scanAppearance,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scanAppearance,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool scanAppearance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: selected ? AppShadows.of(context).soft : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(26),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? Colors.black
                          : scanAppearance
                              ? Colors.white
                              : colors.onSurface,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileQrCode extends StatelessWidget {
  const _ProfileQrCode();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(painter: _QrPatternPainter()),
        ),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const count = 29;
    final cell = size.width / count;
    final paint = Paint()..color = const Color(0xFF050505);

    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) ||
        (x >= count - 8 && y < 8) ||
        (x < 8 && y >= count - 8);

    bool finderPixel(int x, int y) {
      final origins = [(0, 0), (count - 7, 0), (0, count - 7)];
      for (final (ox, oy) in origins) {
        final dx = x - ox;
        final dy = y - oy;
        if (dx >= 0 && dx < 7 && dy >= 0 && dy < 7) {
          return dx == 0 ||
              dx == 6 ||
              dy == 0 ||
              dy == 6 ||
              (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
        }
      }
      return false;
    }

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        if (inFinder(x, y)) {
          if (finderPixel(x, y)) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x * cell, y * cell, cell * .88, cell * .88),
                Radius.circular(cell * .25),
              ),
              paint,
            );
          }
          continue;
        }
        final value = (x * 17 + y * 31 + x * y * 7 + (x ^ y) * 13) % 11;
        if (value < 5) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                x * cell + cell * .08,
                y * cell + cell * .08,
                cell * .78,
                cell * .78,
              ),
              Radius.circular(cell * .38),
            ),
            paint,
          );
        }
      }
    }

    final center = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * .27,
      height: size.height * .27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(center, const Radius.circular(18)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(center.deflate(5), const Radius.circular(14)),
      paint,
    );
    final logo = TextPainter(
      text: const TextSpan(
        text: '↗',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    logo.paint(
      canvas,
      Offset(
        center.center.dx - logo.width / 2,
        center.center.dy - logo.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
