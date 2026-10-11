import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

const _profileImageUrl =
    'https://i.pinimg.com/736x/cf/c0/b5/cfc0b5f17ed198ba268925516db2e951.jpg';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
              return const _AvatarFallback();
            },
            errorBuilder: (context, error, stackTrace) =>
                const _AvatarFallback(),
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 46,
      height: 46,
      child: ColoredBox(
        color: AppColors.outline,
        child: Icon(Icons.person_rounded, color: AppColors.secondaryText),
      ),
    );
  }
}
