import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppAlertType { info, error }

/// Shows the shared in-app alert card above the current screen.
abstract final class AppAlert {
  static _ActiveAlert? _activeAlert;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    AppAlertType type = AppAlertType.info,
    Duration duration = const Duration(seconds: 5),
  }) {
    _activeAlert?.dismiss();
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context, rootOverlay: true);
    final activeAlert = _ActiveAlert();
    final entry = OverlayEntry(
      builder: (overlayContext) {
        final media = MediaQuery.of(overlayContext);
        return Positioned(
          top: media.padding.top + 18,
          left: 16,
          right: 16,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: _AppAlertCard(
                title: title,
                message: message,
                type: type,
                onClose: activeAlert.dismiss,
              ),
            ),
          ),
        );
      },
    );

    activeAlert
      ..entry = entry
      ..timer = Timer(duration, activeAlert.dismiss);
    _activeAlert = activeAlert;
    overlay.insert(entry);
  }
}

class _ActiveAlert {
  OverlayEntry? entry;
  Timer? timer;

  void dismiss() {
    timer?.cancel();
    if (entry?.mounted ?? false) entry!.remove();
    entry = null;
    timer = null;
    if (identical(AppAlert._activeAlert, this)) {
      AppAlert._activeAlert = null;
    }
  }
}

class _AppAlertCard extends StatelessWidget {
  const _AppAlertCard({
    required this.title,
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String title;
  final String message;
  final AppAlertType type;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor =
        type == AppAlertType.error ? colors.error : colors.primary;
    final icon = type == AppAlertType.error
        ? Icons.error_outline_rounded
        : Icons.info_outline_rounded;
    final radius = BorderRadius.circular(30);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, -12 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: colors.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 34),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Dismiss alert',
                  onPressed: onClose,
                  icon:
                      Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
