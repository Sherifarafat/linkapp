import 'package:flutter/material.dart';

import '../../../../app/theme/app_shadows.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onPressed, this.isOpen = false});

  final VoidCallback onPressed;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Add',
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.of(context).soft,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isOpen ? Icons.close_rounded : Icons.add_rounded,
                key: ValueKey(isOpen),
                color: colors.onPrimary,
                size: 27,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
