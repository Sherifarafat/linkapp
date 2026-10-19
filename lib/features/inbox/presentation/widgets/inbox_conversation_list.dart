import 'package:flutter/material.dart';

class InboxConversation {
  const InboxConversation({
    required this.name,
    required this.avatarUrl,
    required this.preview,
    required this.previousPreview,
    required this.date,
    required this.statusColor,
    required this.senderHeading,
    required this.senderEmail,
    required this.messageBody,
    this.unreadCount,
    this.hasAttachment = false,
    this.attachmentName,
    this.isVerified = false,
  });

  final String name;
  final String avatarUrl;
  final String preview;
  final String previousPreview;
  final String date;
  final Color statusColor;
  final String senderHeading;
  final String senderEmail;
  final String messageBody;
  final int? unreadCount;
  final bool hasAttachment;
  final String? attachmentName;
  final bool isVerified;
}

class InboxConversationList extends StatefulWidget {
  const InboxConversationList({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<InboxConversationList> createState() => _InboxConversationListState();
}

enum _InboxFilter { notifications, forYou, messages }

class _InboxConversationListState extends State<InboxConversationList> {
  _InboxFilter _selectedFilter = _InboxFilter.messages;

  static const _conversations = [
    InboxConversation(
      name: 'Eliot Rivers',
      avatarUrl: 'https://i.pravatar.cc/120?img=47',
      preview: 'Find your design muse and let your ideas flow',
      previousPreview: 'In the middle of difficulty lies opportunity',
      date: 'Dec 9',
      statusColor: Color(0xFFF28B35),
      senderHeading: 'Eliot Rivers',
      senderEmail: 'eliot@designmail.io',
      messageBody: '''Hello!

I came across your page and wanted to say how much I enjoy your work. Your latest projects are inspiring.

I attached a few references that might be useful for your next idea.

Talk soon,
Eliot''',
      unreadCount: 2,
      hasAttachment: true,
      attachmentName: 'Design references.pdf',
      isVerified: true,
    ),
    InboxConversation(
      name: 'Sohel',
      avatarUrl: 'https://i.pravatar.cc/120?img=12',
      preview: 'Explore the world of design and find inspiration',
      previousPreview: 'The quick brown fox jumps over the lazy dog',
      date: 'Dec 9',
      statusColor: Color(0xFFF28B35),
      senderHeading: 'Sohel from Canary Mail',
      senderEmail: 'hello@canarymail.io',
      messageBody: '''Hello there!

The first 24 hours after downloading Canary will be full of little discoveries.

Here’s one feature that will change your life. Wondering whether people are reading your email, or are they ignoring you?

Well, wonder no more. With Canary Mail’s read receipts, you can track your email and get the exact information you need to make a decision.

Talk soon,
Sohel
Founder & CEO of Canary Mail''',
      isVerified: true,
    ),
    InboxConversation(
      name: 'Jasper Quinn',
      avatarUrl: 'https://i.pravatar.cc/120?img=5',
      preview: 'Unleash your creativity and discover new ideas',
      previousPreview: 'A journey of a thousand miles begins with one step',
      date: 'Dec 9',
      statusColor: Color(0xFF4567F5),
      senderHeading: 'Jasper Quinn',
      senderEmail: 'jasper@creativemail.io',
      messageBody: '''Hi!

Unleash your creativity and discover new ideas with the latest design collection.

A journey of a thousand miles begins with one step. I’d love to hear what you think when you get a chance to explore it.

Best,
Jasper''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMessages = _selectedFilter == _InboxFilter.messages;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
      sliver: SliverList.builder(
        itemCount: isMessages ? _conversations.length + 1 : 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InboxFilterTabs(
                selected: _selectedFilter,
                isArabic: widget.isArabic,
                onSelected: (filter) => setState(() => _selectedFilter = filter),
              ),
            );
          }
          if (!isMessages) {
            return _InboxFilterEmptyState(
              filter: _selectedFilter,
              isArabic: widget.isArabic,
            );
          }
          return _InboxConversationTile(
            conversation: _conversations[index - 1],
            isArabic: widget.isArabic,
          );
        },
      ),
    );
  }
}

class _InboxFilterTabs extends StatelessWidget {
  const _InboxFilterTabs({
    required this.selected,
    required this.isArabic,
    required this.onSelected,
  });

  final _InboxFilter selected;
  final bool isArabic;
  final ValueChanged<_InboxFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filters = [
      (
        filter: _InboxFilter.notifications,
        label: isArabic ? 'الإشعارات' : 'Notifications',
      ),
      (filter: _InboxFilter.forYou, label: isArabic ? 'لك' : 'For you'),
      (filter: _InboxFilter.messages, label: isArabic ? 'الرسائل' : 'Messages'),
    ];

    return Row(
      children: [
        for (final item in filters)
          Expanded(
            child: InkWell(
              onTap: () => onSelected(item.filter),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: selected == item.filter
                                ? colors.primary
                                : colors.onSurfaceVariant,
                            fontWeight: selected == item.filter
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 9),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2,
                      width: selected == item.filter ? 34 : 0,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InboxFilterEmptyState extends StatelessWidget {
  const _InboxFilterEmptyState({required this.filter, required this.isArabic});

  final _InboxFilter filter;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isNotifications = filter == _InboxFilter.notifications;
    return Padding(
      padding: const EdgeInsets.only(top: 54),
      child: Column(
        children: [
          Icon(
            isNotifications
                ? Icons.notifications_none_rounded
                : Icons.auto_awesome_rounded,
            color: colors.onSurfaceVariant.withValues(alpha: .7),
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? (isNotifications ? 'مفيش إشعارات جديدة' : 'محتوى مقترح لك')
                : (isNotifications
                    ? 'You’re all caught up'
                    : 'Picked for you'),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic
                ? (isNotifications
                    ? 'الإشعارات الجديدة هتظهر هنا'
                    : 'المحتوى المناسب لك هيظهر هنا')
                : (isNotifications
                    ? 'New notifications will show up here'
                    : 'Updates selected for you will show up here'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _InboxConversationTile extends StatelessWidget {
  const _InboxConversationTile({
    required this.conversation,
    required this.isArabic,
  });

  final InboxConversation conversation;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDark ? colors.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _InboxMessageSheet(conversation: conversation),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                _InboxAvatar(conversation: conversation),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conversation.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (conversation.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              color: colors.primary,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        conversation.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.previousPreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: .72,
                                    ),
                                  ),
                            ),
                          ),
                          if (conversation.hasAttachment) ...[
                            const SizedBox(width: 5),
                            Icon(
                              Icons.attach_file_rounded,
                              color: colors.onSurfaceVariant,
                              size: 17,
                            ),
                          ],
                          if (conversation.unreadCount case final count?) ...[
                            const SizedBox(width: 7),
                            Container(
                              constraints: const BoxConstraints(minWidth: 26),
                              height: 26,
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? '9 ديسمبر' : conversation.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: conversation.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InboxAvatar extends StatelessWidget {
  const _InboxAvatar({required this.conversation});

  final InboxConversation conversation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          ClipOval(
            child: Image.network(
              conversation.avatarUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: colors.primaryContainer,
                child: Center(
                  child: Text(
                    conversation.name.substring(0, 1),
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF31B77A),
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxMessageSheet extends StatelessWidget {
  const _InboxMessageSheet({required this.conversation});

  final InboxConversation conversation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      heightFactor: .86,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Material(
          color: colors.surface,
          child: SafeArea(
            top: false,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.onSurfaceVariant.withValues(alpha: .4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InboxAvatar(conversation: conversation),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.senderHeading,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      conversation.senderEmail,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'to: me',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.messageBody,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: .9,
                                      ),
                                      height: 1.55,
                                    ),
                              ),
                              if (conversation.hasAttachment) ...[
                                const SizedBox(height: 22),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf_outlined,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 9),
                                      Text(
                                        conversation.attachmentName ??
                                            'Attachment',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
