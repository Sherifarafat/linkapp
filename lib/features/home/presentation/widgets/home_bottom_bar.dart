import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import 'add_button.dart';
import 'bottom_nav_item.dart';

class HomeBottomBar extends StatefulWidget {
  const HomeBottomBar({
    super.key,
    required this.onAddPressed,
    required this.onTabChanged,
    required this.isArabic,
  });

  final ValueChanged<int> onAddPressed;
  final ValueChanged<String> onTabChanged;
  final bool isArabic;

  @override
  State<HomeBottomBar> createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  int _selectedIndex = 0;
  bool _isAddMenuOpen = false;

  static const _tabs = [
    _TabItem(label: 'Feed', iconAsset: 'assets/icons/icon_01.png'),
    _TabItem(label: 'Inbox', iconAsset: 'assets/icons/icon_02.png'),
    _TabItem(label: 'Statics', iconAsset: 'assets/icons/icon_03.png'),
    _TabItem(label: 'Catalog', iconAsset: 'assets/icons/icon_04.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String tabLabel(_TabItem tab) {
      if (!widget.isArabic) return tab.label;
      return switch (tab.label) {
        'Feed' => 'الرئيسية',
        'Inbox' => 'الوارد',
        'Statics' => 'الإحصائيات',
        'Catalog' => 'الكتالوج',
        _ => tab.label,
      };
    }

    return SafeArea(
      top: false,
      child: Transform.translate(
        offset: const Offset(0, 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubicEmphasized,
                  height: _isAddMenuOpen ? 250 : 62,
                  padding: EdgeInsets.all(_isAddMenuOpen ? 10 : 5),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius:
                        BorderRadius.circular(_isAddMenuOpen ? 26 : 40),
                    boxShadow: AppShadows.of(context).soft,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: .96, end: 1).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                    child: _isAddMenuOpen
                        ? _AddActionsGrid(
                            key: const ValueKey('add-actions'),
                            onAction: (index) {
                              HapticFeedback.mediumImpact();
                              SystemSound.play(SystemSoundType.click);
                              setState(() => _isAddMenuOpen = false);
                              widget.onAddPressed(index);
                            },
                          )
                        : SizedBox.expand(
                            key: const ValueKey('navigation-tabs'),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: ExcludeSemantics(
                                      child: Row(
                                        children: [
                                          for (final tab in _tabs)
                                            Expanded(
                                              child: Center(
                                                child: _NavIcon(
                                                  iconAsset: tab.iconAsset,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 210),
                                  curve: Curves.easeOutCubic,
                                  alignment: Alignment(
                                    -1 +
                                        (_selectedIndex *
                                            2 /
                                            (_tabs.length - 1)),
                                    0,
                                  ),
                                  child: Container(
                                    width: 90,
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.of(context)
                                          .selectedNavContainer,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _NavIcon(
                                          iconAsset:
                                              _tabs[_selectedIndex].iconAsset,
                                          color: colors.onSurface,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            tabLabel(_tabs[_selectedIndex]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: colors.onSurface,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    for (var index = 0;
                                        index < _tabs.length;
                                        index++)
                                      Expanded(
                                        child: BottomNavItem(
                                          iconAsset: _tabs[index].iconAsset,
                                          label: tabLabel(_tabs[index]),
                                          selected: index == _selectedIndex,
                                          onPressed: () {
                                            setState(
                                                () => _selectedIndex = index);
                                            widget.onTabChanged(
                                                _tabs[index].label);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: AddButton(
                  isOpen: _isAddMenuOpen,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    SystemSound.play(SystemSoundType.click);
                    setState(() => _isAddMenuOpen = !_isAddMenuOpen);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.iconAsset, required this.color});

  final String iconAsset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget image() => Image.asset(
          iconAsset,
          width: 22,
          height: 22,
          color: color,
          colorBlendMode: BlendMode.srcIn,
        );

    return SizedBox(
      width: 23,
      height: 23,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0.5, child: image()),
          Positioned(right: 0.5, child: image()),
          Positioned(top: 0.5, child: image()),
          Positioned(bottom: 0.5, child: image()),
          image(),
        ],
      ),
    );
  }
}

class _AddActionsGrid extends StatelessWidget {
  const _AddActionsGrid({super.key, required this.onAction});

  final ValueChanged<int> onAction;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _AddAction(
            iconAsset: 'assets/icons/add_actions/upload_file.png',
            label: isArabic ? 'رفع ملف' : 'Upload file',
            onTap: () => onAction(0)),
        _AddAction(
            iconAsset: 'assets/icons/add_actions/custom_link.png',
            label: isArabic ? 'رابط مخصص' : 'Custom link',
            onTap: () => onAction(1)),
        _AddAction(
            iconAsset: 'assets/icons/add_actions/go_to.png',
            label: isArabic ? 'انتقال إلى' : 'Go to',
            onTap: () => onAction(2)),
        _AddAction(
            iconAsset: 'assets/icons/add_actions/alert.png',
            label: isArabic ? 'تنبيه' : 'Alert',
            onTap: () => onAction(3)),
        _AddAction(
            iconAsset: 'assets/icons/add_actions/rating.png',
            label: isArabic ? 'تقييم' : 'Rating',
            onTap: () => onAction(4)),
        _AddAction(
            iconAsset: 'assets/icons/add_actions/add_banner.png',
            label: isArabic ? 'إضافة بانر' : 'Add banner',
            onTap: () => onAction(5)),
      ],
    );
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction(
      {required this.iconAsset, required this.label, required this.onTap});
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.of(context).iconTileContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      iconAsset,
                      width: 25,
                      height: 25,
                      color: Theme.of(context).colorScheme.onSurface,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                ],
              ),
            ),
          ),
        ),
      );
}

class _TabItem {
  const _TabItem({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}
