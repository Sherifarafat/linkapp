import 'package:flutter/material.dart';

import '../../../../app/widgets/app_alert.dart';

class HomeActionsSheet extends StatefulWidget {
  const HomeActionsSheet({
    super.key,
    required this.isDarkMode,
    required this.isArabic,
    required this.onThemeToggle,
    required this.onLanguageToggle,
    required this.onLogout,
  });

  final bool isDarkMode;
  final bool isArabic;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;
  final VoidCallback onLogout;

  @override
  State<HomeActionsSheet> createState() => _HomeActionsSheetState();
}

class _HomeActionsSheetState extends State<HomeActionsSheet> {
  late bool _isDarkMode;
  late bool _isArabic;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _isArabic = widget.isArabic;
  }

  String _text(String english, String arabic) => _isArabic ? arabic : english;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  _text('Menu', 'القائمة'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              _ActionRow(
                icon: _isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: _text('Dark mode', 'الوضع الداكن'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (_) {
                    setState(() => _isDarkMode = !_isDarkMode);
                    widget.onThemeToggle();
                  },
                ),
              ),
              _ActionRow(
                icon: Icons.language_rounded,
                title: _text('Language', 'اللغة'),
                trailing: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('EN')),
                    ButtonSegment(value: true, label: Text('ع')),
                  ],
                  selected: {_isArabic},
                  onSelectionChanged: (selection) {
                    final arabic = selection.first;
                    if (arabic == _isArabic) return;
                    setState(() => _isArabic = arabic);
                    widget.onLanguageToggle();
                  },
                ),
              ),
              const Divider(height: 20),
              _ActionRow(
                icon: Icons.help_outline_rounded,
                title: _text('Help', 'المساعدة'),
                onTap: () => AppAlert.show(
                  context,
                  title: _text('Help', 'المساعدة'),
                  message: _text(
                    'Tap the Add button to create a link, then choose a category.',
                    'اضغط على زر الإضافة لإنشاء رابط، ثم اختر التصنيف المناسب.',
                  ),
                ),
              ),
              _ActionRow(
                icon: Icons.support_agent_rounded,
                title: _text('Support', 'الدعم'),
                onTap: () => AppAlert.show(
                  context,
                  title: _text('Support', 'الدعم'),
                  message: _text(
                    'Support options will be available here.',
                    'خيارات التواصل مع الدعم هتكون متاحة هنا.',
                  ),
                ),
              ),
              _ActionRow(
                icon: Icons.logout_rounded,
                title: _text('Log out', 'تسجيل الخروج'),
                iconColor: colors.error,
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('Log out?', 'تسجيل الخروج؟')),
        content: Text(
          _text('Are you sure you want to log out?', 'هل تريد تسجيل الخروج؟'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_text('Cancel', 'إلغاء')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_text('Log out', 'تسجيل الخروج')),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      Navigator.of(context).pop();
      widget.onLogout();
    }
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? colors.onSurfaceVariant),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
