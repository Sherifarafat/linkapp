import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Menu',
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              Icons.menu_rounded,
              color: AppColors.onSurface,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
