import 'package:flutter/material.dart';

import '../widgets/home_bottom_bar.dart';
import '../widgets/home_actions_sheet.dart';
import '../widgets/home_header.dart';
import '../widgets/create_link_sheet.dart';
import 'profile_page.dart';
import '../../../rating/presentation/pages/rating_page.dart';
import '../../../pay_coffee/presentation/widgets/pay_coffee_sheet.dart';
import '../../../inbox/presentation/widgets/inbox_conversation_list.dart';
import '../../../analytics/presentation/widgets/analytics_date_selector.dart';
import '../../../analytics/presentation/widgets/analytics_sales_card.dart';
import '../../../analytics/presentation/widgets/analytics_device_breakdown.dart';
import '../../../analytics/presentation/widgets/analytics_top_countries.dart';
import '../../../analytics/presentation/widgets/analytics_traffic_time.dart';
import '../../../../app/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.isArabic,
    required this.accentColor,
    required this.onAccentColorChanged,
    required this.onThemeToggle,
    required this.onLanguageToggle,
  });

  final bool isDarkMode;
  final bool isArabic;
  final AppAccentColor accentColor;
  final ValueChanged<AppAccentColor> onAccentColorChanged;
  final VoidCallback onThemeToggle;
  final VoidCallback onLanguageToggle;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedTab = 'Feed';
  final List<CreateLinkDraft> _createdLinks = [];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final homeItems = _createdLinks.isEmpty
        ? <Widget>[
            _PreviewLinkTile(
              icon: Icons.alternate_email_rounded,
              title: widget.isArabic ? 'إنستجرام' : 'Instagram',
              subtitle: '@sherifarafat2000',
              color: colors.primary,
            ),
            _PreviewLinkTile(
              icon: Icons.language_rounded,
              title: widget.isArabic ? 'موقعي' : 'My website',
              subtitle: 'sherifarafat.com',
              color: colors.secondary,
            ),
            _PreviewLinkTile(
              icon: Icons.play_circle_outline_rounded,
              title: widget.isArabic ? 'أحدث فيديو' : 'Latest video',
              subtitle: 'youtube.com/@sherifarafat',
              color: colors.tertiary,
            ),
            _PreviewLinkTile(
              icon: Icons.work_outline_rounded,
              title: widget.isArabic ? 'ملفي المهني' : 'Portfolio',
              subtitle: 'sherifarafat.com/work',
              color: colors.primary,
            ),
            _PreviewLinkTile(
              icon: Icons.mail_outline_rounded,
              title: widget.isArabic ? 'تواصل معي' : 'Contact me',
              subtitle: 'hello@sherifarafat.com',
              color: colors.secondary,
            ),
            _PreviewLinkTile(
              icon: Icons.photo_camera_outlined,
              title: widget.isArabic ? 'معرض الصور' : 'Photo gallery',
              subtitle: 'photos.sherifarafat.com',
              color: colors.tertiary,
            ),
            _PreviewLinkTile(
              icon: Icons.description_outlined,
              title: widget.isArabic ? 'السيرة الذاتية' : 'Resume',
              subtitle: 'sherifarafat.com/cv',
              color: colors.primary,
            ),
            _PreviewLinkTile(
              icon: Icons.code_rounded,
              title: widget.isArabic ? 'مشاريعي' : 'My projects',
              subtitle: 'github.com/sherifarafat',
              color: colors.secondary,
            ),
            _PreviewLinkTile(
              icon: Icons.podcasts_rounded,
              title: widget.isArabic ? 'البودكاست' : 'Podcast',
              subtitle: 'Listen to my latest episode',
              color: colors.tertiary,
            ),
            _PreviewLinkTile(
              icon: Icons.shopping_bag_outlined,
              title: widget.isArabic ? 'المتجر' : 'My store',
              subtitle: 'shop.sherifarafat.com',
              color: colors.primary,
            ),
            _PreviewLinkTile(
              icon: Icons.event_outlined,
              title: widget.isArabic ? 'احجز موعدًا' : 'Book a meeting',
              subtitle: 'Choose a time to meet',
              color: colors.secondary,
            ),
            _PreviewLinkTile(
              icon: Icons.favorite_border_rounded,
              title: widget.isArabic ? 'ادعمني' : 'Support my work',
              subtitle: 'Buy me a coffee',
              color: colors.tertiary,
            ),
          ]
        : _createdLinks.map((draft) => _CreatedLinkTile(draft: draft)).toList();

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeHeaderDelegate(
                title: _localizedTabTitle,
                isDarkMode: widget.isDarkMode,
                onMenuPressed: _openMenu,
                onProfilePressed: _openProfile,
                onThemeToggle: widget.onThemeToggle,
                headerColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            if (_selectedTab == 'Analytics')
              ...[
                AnalyticsDateSelector(isArabic: widget.isArabic),
                AnalyticsSalesCard(isArabic: widget.isArabic),
                AnalyticsDeviceBreakdown(isArabic: widget.isArabic),
                AnalyticsTopCountries(isArabic: widget.isArabic),
                AnalyticsTrafficTime(isArabic: widget.isArabic),
              ]
            else if (_selectedTab == 'Inbox')
              InboxConversationList(isArabic: widget.isArabic)
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => index.isEven
                        ? homeItems[index ~/ 2]
                        : const SizedBox(height: 10),
                    childCount:
                        homeItems.isEmpty ? 0 : homeItems.length * 2 - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(
        onAddPressed: (action) => _openCreateSheet(action),
        onTabChanged: (tab) => setState(() => _selectedTab = tab),
        isArabic: widget.isArabic,
      ),
    );
  }

  String get _localizedTabTitle {
    if (!widget.isArabic) return _selectedTab;
    return switch (_selectedTab) {
      'Feed' => 'الرئيسية',
      'Inbox' => 'الوارد',
      'Analytics' => 'الإحصائيات',
      'Catalog' => 'الكتالوج',
      _ => _selectedTab,
    };
  }

  void _openMenu() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeActionsSheet(
        isDarkMode: widget.isDarkMode,
        isArabic: widget.isArabic,
        accentColor: widget.accentColor,
        onAccentColorChanged: (color) {
          widget.onAccentColorChanged(color);
          setState(() {});
        },
        onThemeToggle: widget.onThemeToggle,
        onLanguageToggle: widget.onLanguageToggle,
        onLogout: () {
          setState(() {
            _createdLinks.clear();
            _selectedTab = 'Feed';
          });
        },
      ),
    );
  }

  void _openProfile() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.78,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: const ProfilePage(),
        ),
      ),
    );
  }

  void _openCreateSheet(int action) {
    if (action == 6) {
      final messenger = ScaffoldMessenger.of(context);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PayCoffeeSheet(
          isArabic: widget.isArabic,
          onConfirm: (_) {
            Navigator.of(context).pop();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  widget.isArabic
                      ? 'إعداد الدفع هيكون متاح قريبًا.'
                      : 'Payment setup is coming soon.',
                ),
              ),
            );
          },
        ),
      );
      return;
    }

    if (action == 4) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RatingPage(isArabic: widget.isArabic),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateLinkSheet(
        initialCategory: switch (action) {
          0 => 'File',
          1 || 2 => 'Custom link',
          3 => 'Alert',
          4 => 'Rating',
          5 => 'Banner image',
          _ => null,
        },
        initialSubcategory: null,
        onCreate: (draft) => setState(() => _createdLinks.insert(0, draft)),
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HomeHeaderDelegate({
    required this.title,
    required this.isDarkMode,
    required this.onMenuPressed,
    required this.onProfilePressed,
    required this.onThemeToggle,
    required this.headerColor,
  });

  final String title;
  final bool isDarkMode;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onThemeToggle;
  final Color headerColor;

  @override
  double get minExtent => 62;

  @override
  double get maxExtent => 142;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return SizedBox.expand(
      child: AnimatedContainer(
        duration: Duration.zero,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              headerColor.withValues(alpha: .96),
              headerColor.withValues(alpha: .08),
            ],
          ),
        ),
        child: HomeHeader(
          title: title,
          collapseProgress: progress,
          onMenuPressed: onMenuPressed,
          onProfilePressed: onProfilePressed,
          isDarkMode: isDarkMode,
          onThemeToggle: onThemeToggle,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) =>
      title != oldDelegate.title ||
      isDarkMode != oldDelegate.isDarkMode ||
      onMenuPressed != oldDelegate.onMenuPressed ||
      onProfilePressed != oldDelegate.onProfilePressed ||
      onThemeToggle != oldDelegate.onThemeToggle ||
      headerColor != oldDelegate.headerColor;
}

class _PreviewLinkTile extends StatelessWidget {
  const _PreviewLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      ),
    );
  }
}

class _CreatedLinkTile extends StatelessWidget {
  const _CreatedLinkTile({required this.draft});

  final CreateLinkDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final detail = draft.attachmentName ??
        draft.generatedLink ??
        (draft.subcategory.isNotEmpty ? draft.subcategory : draft.category);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.link_rounded, color: colors.primary),
        ),
        title: Text(draft.title),
        subtitle: Text(detail),
        trailing: const Icon(Icons.more_horiz_rounded),
      ),
    );
  }
}
