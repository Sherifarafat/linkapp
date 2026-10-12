import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

const _profileImageUrl =
    'https://i.pinimg.com/736x/cf/c0/b5/cfc0b5f17ed198ba268925516db2e951.jpg';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    return Semantics(
      button: true,
      label: 'Profile',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: ClipOval(
          child: Image.network(
            _profileImageUrl,
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _AvatarFallback(
                  background: colors.outlineVariant,
                  foreground: appColors.secondaryText);
            },
            errorBuilder: (context, error, stackTrace) => _AvatarFallback(
                background: colors.outlineVariant,
                foreground: appColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: ColoredBox(
        color: background,
        child: Icon(Icons.person_rounded, color: foreground),
      ),
    );
  }
}
