import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/widgets/app_alert.dart';
import '../../../../app/theme/app_colors.dart';

class CreateLinkDraft {
  const CreateLinkDraft({
    required this.title,
    required this.category,
    required this.subcategory,
    this.attachment,
    this.attachmentName,
    this.generatedLink,
  });

  final String title;
  final String category;
  final String subcategory;
  final PlatformFile? attachment;
  final String? attachmentName;
  final String? generatedLink;
}

class CreateLinkSheet extends StatefulWidget {
  const CreateLinkSheet({
    super.key,
    required this.onCreate,
    this.initialCategory,
    this.initialSubcategory,
  });

  final ValueChanged<CreateLinkDraft> onCreate;
  final String? initialCategory;
  final String? initialSubcategory;

  @override
  State<CreateLinkSheet> createState() => _CreateLinkSheetState();
}

class _CreateLinkSheetState extends State<CreateLinkSheet> {
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _sheetController = DraggableScrollableController();

  _LinkCategory? _category;
  String? _subcategory;
  PlatformFile? _attachment;
  String? _generatedLink;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    final name = widget.initialCategory;
    if (name != null) {
      _category =
          _categories.where((category) => category.name == name).firstOrNull;
    }
    _subcategory = widget.initialSubcategory;
  }

  static const _categories = [
    _LinkCategory('Social links', Icons.people_alt_outlined),
    _LinkCategory('Custom link', Icons.link_rounded),
    _LinkCategory('File', Icons.description_outlined),
    _LinkCategory('Banner image', Icons.image_outlined),
    _LinkCategory('Go to', Icons.open_in_new_rounded),
    _LinkCategory('Alert', Icons.notifications_outlined),
    _LinkCategory('Rating', Icons.star_outline_rounded),
  ];

  static const _socialPlatforms = ['Facebook', 'WhatsApp', 'Instagram'];

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _resizeSheet(double size) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sheetController.isAttached) {
        _sheetController.animateTo(
          size,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _selectCategory(_LinkCategory category) {
    setState(() {
      _category = category;
      _subcategory = null;
      _attachment = null;
      _generatedLink = null;
    });
    _resizeSheet(category.name == 'Custom link' ? 0.82 : 0.72);
  }

  Future<void> _pickFile() async {
    final isImage = _category?.name == 'Banner image';
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isImage
            ? const ['png', 'jpg', 'jpeg']
            : const ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      setState(() => _attachment = result.files.single);
      _resizeSheet(0.78);
    } catch (_) {
      if (!mounted) return;
      AppAlert.show(
        context,
        title: 'File picker unavailable',
        message: 'Could not open files. Please try again.',
        type: AppAlertType.error,
      );
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _generateCustomLink() {
    final slug =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).substring(4);
    setState(() => _generatedLink = 'link.app/$slug');
    _resizeSheet(0.86);
  }

  bool get _canCreate {
    if (_titleController.text.trim().isEmpty || _category == null) return false;
    switch (_category!.name) {
      case 'Social links':
        return _subcategory != null;
      case 'Custom link':
        return _subcategory == 'Generate custom link' &&
            _destinationController.text.trim().isNotEmpty &&
            _generatedLink != null;
      case 'File':
      case 'Banner image':
        return _attachment != null;
      case 'Go to':
      case 'Alert':
      case 'Rating':
        return true;
      default:
        return false;
    }
  }

  void _create() {
    if (!_canCreate) return;
    widget.onCreate(
      CreateLinkDraft(
        title: _titleController.text.trim(),
        category: _category!.name,
        subcategory: _subcategory ?? '',
        attachment: _attachment,
        attachmentName: _attachment?.name,
        generatedLink: _generatedLink,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.56,
      minChildSize: 0.46,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.56, 0.72, 0.86, 0.92],
      builder: (context, scrollController) {
        return Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.outlineVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Create link',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 24),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Title',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Create title',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Choose a category',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 62,
                          ),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final selected = _category == category;
                            return _CategoryTile(
                              category: category,
                              selected: selected,
                              onTap: () => _selectCategory(category),
                            );
                          },
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: _buildSubcategoryContent(
                            context,
                            colors,
                            appColors,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canCreate ? _create : null,
                            child: const Text('Create'),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.viewInsetsOf(context).bottom > 0
                              ? 16
                              : 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryContent(
    BuildContext context,
    ColorScheme colors,
    AppColors appColors,
  ) {
    if (_category == null) return const SizedBox.shrink();

    switch (_category!.name) {
      case 'Social links':
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose a social platform',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _socialPlatforms
                    .map(
                      (platform) => ChoiceChip(
                        label: Text(platform),
                        selected: _subcategory == platform,
                        onSelected: (_) => setState(() {
                          _subcategory = platform;
                        }),
                        selectedColor: appColors.selectedNavContainer,
                        side: BorderSide(
                          color: _subcategory == platform
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      case 'Custom link':
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subcategory',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Generate custom link',
                selected: _subcategory == 'Generate custom link',
                onTap: () {
                  setState(() {
                    _subcategory = 'Generate custom link';
                    _generatedLink = null;
                  });
                  _resizeSheet(0.82);
                },
              ),
              if (_subcategory == 'Generate custom link') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() => _generatedLink = null),
                  decoration: const InputDecoration(
                    hintText: 'Paste destination URL',
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _destinationController.text.trim().isEmpty
                      ? null
                      : _generateCustomLink,
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Generate custom link'),
                ),
                if (_generatedLink != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SelectableText(
                      _generatedLink!,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      case 'File':
      case 'Banner image':
        final isImage = _category!.name == 'Banner image';
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isImage ? 'Upload a banner image' : 'Upload a document',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: isImage
                    ? Icons.add_photo_alternate_outlined
                    : Icons.upload_file_rounded,
                title: _isPickingFile
                    ? 'Opening files…'
                    : _attachment?.name ??
                        (isImage ? 'Choose PNG or JPG' : 'Choose PDF or DOC'),
                subtitle: _attachment == null
                    ? (isImage ? 'PNG, JPG, JPEG' : 'PDF, DOC, DOCX')
                    : _formatFileSize(_attachment!.size),
                selected: _attachment != null,
                onTap: _isPickingFile ? null : _pickFile,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _LinkCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? AppColors.of(context).selectedNavContainer
          : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(category.icon, size: 20, color: colors.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? AppColors.of(context).selectedNavContainer
          : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyLarge),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkCategory {
  const _LinkCategory(this.name, this.icon);

  final String name;
  final IconData icon;
}
