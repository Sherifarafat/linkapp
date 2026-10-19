import 'package:flutter/material.dart';

import '../../data/models/rating_model.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({super.key, required this.isArabic});

  final bool isArabic;

  static const _summary = RatingSummary(average: 4.8, count: 128);
  static const _reviews = [
    RatingReview(
      name: 'Olivia Martin',
      avatarUrl: 'https://i.pravatar.cc/120?img=47',
      stars: 5,
      comment: 'Everything I need is finally in one place. Love how easy it is to use!',
    ),
    RatingReview(
      name: 'Ethan Walker',
      avatarUrl: 'https://i.pravatar.cc/120?img=12',
      stars: 5,
      comment: 'Clean, simple, and looks great when I share my page.',
    ),
    RatingReview(
      name: 'Maya Chen',
      avatarUrl: 'https://i.pravatar.cc/120?img=44',
      stars: 4,
      comment: 'The catalog feature makes sharing my products so much easier.',
    ),
    RatingReview(
      name: 'Lucas Reed',
      avatarUrl: 'https://i.pravatar.cc/120?img=5',
      stars: 5,
    ),
  ];

  String _text(String english, String arabic) => isArabic ? arabic : english;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      _HeaderCircleButton(
                        tooltip: _text('Close', 'إغلاق'),
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _HeaderMenuButton(
                        isArabic: isArabic,
                        onSelected: (value) {
                          if (value == 'share') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _text(
                                    'Sharing will be available soon.',
                                    'مشاركة التقييمات هتكون متاحة قريبًا.',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _text('Rating', 'التقييمات'),
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _RatingSummaryCard(
                    summary: _summary,
                    ratingText: _text('rating', 'تقييم'),
                    ratingsText: _text('ratings', 'تقييم'),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    _text('Reviews', 'آراء المستخدمين'),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < _reviews.length; index++) ...[
                    _ReviewTile(
                      review: _reviews[index],
                    ),
                    if (index != _reviews.length - 1)
                      Divider(
                        height: 1,
                        indent: 72,
                        color: colors.outlineVariant.withValues(alpha: .55),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: colors.onSurface,
        constraints: const BoxConstraints.tightFor(width: 46, height: 46),
      ),
    );
  }
}

class _HeaderMenuButton extends StatelessWidget {
  const _HeaderMenuButton({required this.isArabic, required this.onSelected});

  final bool isArabic;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        tooltip: isArabic ? 'القائمة' : 'Menu',
        onSelected: onSelected,
        icon: Icon(Icons.more_horiz_rounded, color: colors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                const Icon(Icons.share_outlined, size: 20),
                const SizedBox(width: 12),
                Text(isArabic ? 'مشاركة التقييمات' : 'Share ratings'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard({
    required this.summary,
    required this.ratingText,
    required this.ratingsText,
  });

  final RatingSummary summary;
  final String ratingText;
  final String ratingsText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final starColor = const Color(0xFFFFB547);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: isDark ? .3 : .55),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.average.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 9),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < summary.average.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: starColor,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${summary.count} $ratingsText',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 1,
            height: 74,
            color: colors.outlineVariant.withValues(alpha: .65),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4.8 / 5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  ratingText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final RatingReview review;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final starColor = const Color(0xFFFFB547);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewAvatar(review: review),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: starColor, size: 17),
                        const SizedBox(width: 3),
                        Text(
                          '${review.stars}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ],
                ),
                if (review.comment case final comment?) ...[
                  const SizedBox(height: 5),
                  Text(
                    comment,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({required this.review});

  final RatingReview review;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipOval(
      child: Image.network(
        review.avatarUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: colors.primaryContainer,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Text(
                review.name.substring(0, 1),
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
