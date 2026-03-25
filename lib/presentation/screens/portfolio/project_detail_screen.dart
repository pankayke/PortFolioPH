import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/date_formatter.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/screens/portfolio/add_edit_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  final int userId;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.userId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _activeImageIndex = 0;

  List<String> get _images {
    if (widget.project.imagePaths.isNotEmpty) return widget.project.imagePaths;
    if (widget.project.thumbnailPath == null) return const [];
    return [widget.project.thumbnailPath!];
  }

  Future<void> _editProject() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditProjectScreen(
          userId: widget.userId,
          portfolioId: widget.project.portfolioId,
          initialProject: widget.project,
        ),
      ),
    );

    if (!mounted || result != true) return;
    Navigator.of(context).pop();
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text(
          'This will permanently remove this portfolio entry and its gallery images from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final provider = context.read<PortfolioProvider>();
    final success = await provider.deleteProject(
      projectId: widget.project.id!,
      userId: widget.userId,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to delete entry.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = widget.project.title;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Entry Details'),
        actions: [
          IconButton(
            onPressed: _editProject,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit entry',
          ),
          IconButton(
            onPressed: _deleteProject,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete entry',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          _AnimatedIn(
            delayMs: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.14),
                    colorScheme.secondary.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _AnimatedIn(
            delayMs: 60,
            child: Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: [
                if ((widget.project.techStack ?? '').trim().isNotEmpty)
                  _TagChip(label: widget.project.techStack!),
                if (widget.project.isFeatured)
                  const _TagChip(label: 'Featured'),
                _TagChip(
                  label: AppDateFormatter.formatDateRange(
                    widget.project.startDate,
                    widget.project.endDate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          if (_images.isNotEmpty) ...[
            _AnimatedIn(
              delayMs: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _activeImageIndex = index;
                      });
                    },
                    itemBuilder: (_, index) {
                      return Hero(
                        tag: 'project_image_${widget.project.id ?? 0}_$index',
                        child: Image.file(
                          File(_images[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            _AnimatedIn(
              delayMs: 160,
              child: Row(
                children: [
                  Text(
                    'Image ${_activeImageIndex + 1} of ${_images.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: List.generate(_images.length, (index) {
                      final isActive = index == _activeImageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isActive ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          if ((widget.project.description ?? '').trim().isNotEmpty) ...[
            _AnimatedIn(
              delayMs: 200,
              child: Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            _AnimatedIn(delayMs: 230, child: Text(widget.project.description!)),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          if ((widget.project.repositoryUrl ?? '').trim().isNotEmpty) ...[
            _AnimatedIn(
              delayMs: 260,
              child: _LinkCard(
                icon: Icons.code_rounded,
                title: 'Reference Link',
                value: widget.project.repositoryUrl!,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],

          if ((widget.project.liveDemoUrl ?? '').trim().isNotEmpty) ...[
            _AnimatedIn(
              delayMs: 300,
              child: _LinkCard(
                icon: Icons.link_rounded,
                title: 'Output Link',
                value: widget.project.liveDemoUrl!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedIn extends StatelessWidget {
  final int delayMs;
  final Widget child;

  const _AnimatedIn({required this.delayMs, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _LinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _LinkCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copy link',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
              },
              icon: const Icon(Icons.content_copy_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}
