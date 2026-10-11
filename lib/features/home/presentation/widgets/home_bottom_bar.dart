import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'add_button.dart';
import 'bottom_nav_item.dart';

class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabItem(label: 'Feed', iconAsset: 'assets/icons/icon_01.png'),
    _TabItem(label: 'Catalog', iconAsset: 'assets/icons/icon_02.png'),
    _TabItem(label: 'Statics', iconAsset: 'assets/icons/icon_03.png'),
    _TabItem(label: 'Inbox', iconAsset: 'assets/icons/icon_04.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 62,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var index = 0; index < _tabs.length; index++)
                      Expanded(
                        flex: index == _selectedIndex ? 2 : 1,
                        child: BottomNavItem(
                          iconAsset: _tabs[index].iconAsset,
                          label: _tabs[index].label,
                          selected: index == _selectedIndex,
                          onPressed: () => setState(() => _selectedIndex = index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            AddButton(onPressed: widget.onAddPressed),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}
