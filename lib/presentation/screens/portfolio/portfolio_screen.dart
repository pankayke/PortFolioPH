import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/core/styling/glass_constants.dart';
import 'package:portfolioph/core/utils/date_formatter.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/screens/portfolio/add_edit_project_screen.dart';
import 'package:portfolioph/presentation/screens/portfolio/project_detail_screen.dart';
import 'package:portfolioph/presentation/widgets/dark_scaffold_with_bottom_nav.dart';
import 'package:portfolioph/presentation/widgets/glass/glass_container.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin, BokehAnimationMixin, UserAwareScreenMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeBokehAnimation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    disposeBokehAnimation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDataForUserWithId((userId) {
      context.read<PortfolioProvider>().loadForUser(userId);
    });
  }

  Future<void> _openCreateProjectSheet() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<PortfolioProvider>();
    final userId = auth.currentUser?.id;
    final portfolioId = provider.selectedPortfolioId;

    if (userId == null || portfolioId == null) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddEditProjectScreen(userId: userId, portfolioId: portfolioId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage your portfolio.')),
      );
    }

    return PremiumAppBackground(
      animation: bokehController,
      child: DarkScaffoldWithBottomNav(
        appBar: AppBar(
          title: const Text('Portfolio Gallery'),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: themeProvider.themeMode == ThemeMode.dark
                      ? const Icon(Icons.light_mode_outlined)
                      : const Icon(Icons.dark_mode_outlined),
                  tooltip: 'Toggle theme',
                  onPressed: () => themeProvider.toggleDarkMode(),
                );
              },
            ),
          ],
        ),
        body: Consumer<PortfolioProvider>(
          builder: (context, provider, _) {
            final bottomInset = DarkScaffoldWithBottomNav.scrollBottomInset(
              context,
              extraClearance: 88,
            );

            return RefreshIndicator(
              onRefresh: () => provider.loadForUser(user.id!),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText:
                                'Search title, description, or tools used',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.updateSearchQuery('');
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                          onChanged: (value) {
                            provider.updateSearchQuery(value);
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        DropdownButtonFormField<int>(
                          initialValue: provider.selectedPortfolioId,
                          decoration: const InputDecoration(
                            labelText: 'Portfolio',
                            prefixIcon: Icon(Icons.folder_open_outlined),
                          ),
                          items: provider.portfolios
                              .where((portfolio) => portfolio.id != null)
                              .map(
                                (portfolio) => DropdownMenuItem<int>(
                                  value: portfolio.id!,
                                  child: Text(portfolio.title),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (portfolioId) {
                            if (portfolioId == null) return;
                            provider.selectPortfolio(portfolioId);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Portfolio Entries (${provider.projects.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            if (provider.searchQuery.isNotEmpty)
                              Text(
                                'Filter active',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                          child: const Text(
                            'Show your strongest work samples. Add complete descriptions and updated links so recruiters can evaluate your portfolio quickly.',
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (provider.isLoading && provider.projects.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const _ProjectCardSkeleton(),
                          childCount: 6,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.76,
                            ),
                      ),
                    )
                  else if (provider.projects.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                        child: _EmptyProjectsState(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final project = provider.projects[index];
                          return _ProjectCard(
                            project: project,
                            compact: index.isOdd,
                            animationIndex: index,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailScreen(
                                    project: project,
                                    userId: user.id!,
                                  ),
                                ),
                              );
                            },
                          );
                        }, childCount: provider.projects.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.78,
                            ),
                      ),
                    ),
                  if (provider.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
                        child: Text(
                          provider.errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab_portfolio',
          onPressed: _openCreateProjectSheet,
          tooltip: 'Add Entry',
          icon: const Icon(Icons.add),
          label: const Text('Add Entry'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final bool compact;
  final int animationIndex;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    this.compact = false,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final coverImage = project.imagePaths.isNotEmpty
        ? project.imagePaths.first
        : project.thumbnailPath;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + ((animationIndex % 8) * 35)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: AppConstants.radiusMd,
        blurStrength: GlassConstants.blurSm,
        opacity: GlassConstants.opacityGlassMd,
        borderOpacity: GlassConstants.opacityBorderMd,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: compact ? 1.15 : 1.0,
                  child: coverImage == null
                      ? Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_outlined),
                        )
                      : _buildProjectImage(coverImage),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (project.isFeatured)
                    const Icon(
                      Icons.star_rounded,
                      color: AppConstants.warningColor,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                project.description?.trim().isNotEmpty == true
                    ? project.description!
                    : 'No description yet.',
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                AppDateFormatter.formatDateRange(
                  project.startDate,
                  project.endDate,
                ),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildProjectImage(String imagePath) {
  if (imagePath.startsWith('data:image/')) {
    final commaIndex = imagePath.indexOf(',');
    if (commaIndex > -1) {
      try {
        final bytes = base64Decode(imagePath.substring(commaIndex + 1));
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        );
      } catch (_) {
        return Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        );
      }
    }
  }

  return Image.file(
    File(imagePath),
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined),
    ),
  );
}

class _ProjectCardSkeleton extends StatelessWidget {
  const _ProjectCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return GlassContainer(
      padding: const EdgeInsets.all(10),
      borderRadius: AppConstants.radiusMd,
      blurStrength: GlassConstants.blurSm,
      opacity: GlassConstants.opacityGlassMd,
      borderOpacity: GlassConstants.opacityBorderMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: base.withAlpha((200 * 0.3).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 12, width: 90, color: base),
          const SizedBox(height: 6),
          Container(height: 10, width: 130, color: base),
        ],
      ),
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  const _EmptyProjectsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.folder_open_outlined),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'No entries yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          const Text('Tap "Add Entry" to add your first portfolio item.'),
        ],
      ),
    );
  }
}
