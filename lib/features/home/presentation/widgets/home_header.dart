import 'package:flutter/material.dart';

import 'menu_button.dart';
import 'profile_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MenuButton(onPressed: onMenuPressed),
        const Spacer(),
        ProfileAvatar(onPressed: onProfilePressed),
      ],
    );
  }
}
