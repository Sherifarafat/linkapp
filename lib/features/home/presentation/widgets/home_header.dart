import 'package:flutter/material.dart';

import 'menu_button.dart';
import 'profile_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.title,
    required this.collapseProgress,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String title;
  final double collapseProgress;

  @override
  Widget build(BuildContext context) {
    final progress = collapseProgress.clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IgnorePointer(
                  ignoring: progress >= 0.98,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: MenuButton(onPressed: onMenuPressed),
                  ),
                ),
                const Spacer(),
                _ThemeToggleButton(
                    isDarkMode: isDarkMode, onPressed: onThemeToggle),
                const SizedBox(width: 12),
                ProfileAvatar(onPressed: onProfilePressed),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 78 - (71 * progress),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 34 - (13 * progress),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.isDarkMode, required this.onPressed});

  final bool isDarkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      child: Material(
        color: colors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colors.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
