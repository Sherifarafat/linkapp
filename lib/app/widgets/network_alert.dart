import 'package:flutter/material.dart';

/// One shared, non-dismissible-until-acknowledged alert for network failures.
abstract final class NetworkAlert {
  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required bool isArabic,
  }) async {
    if (!context.mounted || _isShowing) return;
    await showOnNavigator(
      Navigator.of(context, rootNavigator: true),
      isArabic: isArabic,
    );
  }

  static Future<void> showOnNavigator(
    NavigatorState navigator, {
    required bool isArabic,
  }) async {
    if (!navigator.mounted || _isShowing) return;
    _isShowing = true;
    try {
      await navigator.push<void>(
        DialogRoute<void>(
          context: navigator.context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => _NetworkAlertDialog(isArabic: isArabic),
        ),
      );
    } finally {
      _isShowing = false;
    }
  }
}

class _NetworkAlertDialog extends StatelessWidget {
  const _NetworkAlertDialog({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = colors.onSurface;
    final mutedColor = colors.onSurfaceVariant;
    final radius = BorderRadius.circular(30);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : colors.surface,
            borderRadius: radius,
            border: Border.all(color: colors.outlineVariant.withValues(alpha: .5)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: .24),
                blurRadius: 34,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF78D64B).withValues(alpha: .13),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFF78D64B),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'مشكلة في الاتصال بالإنترنت' : 'Network problem',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          isArabic
                              ? 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى'
                              : 'Check your internet connection and try again',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: mutedColor,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isDark ? const Color(0xFF38383A) : colors.primary,
                    foregroundColor:
                        isDark ? Colors.white : colors.onPrimary,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(isArabic ? 'حسنًا' : 'OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
