// lib/presentation/widgets/skeleton_loader.dart
// ─────────────────────────────────────────────────────────────────────────────
// Skeleton/loading UI placeholders for improved UX
// Shows shimmer effect while data is loading
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Animated skeleton loader with shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets margin;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.margin = EdgeInsets.zero,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 - (_animationController.value * 2), 0),
                end: Alignment(1.0 - (_animationController.value * 2), 0),
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[200]!,
                  Colors.grey[300]!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: widget.borderRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pre-built skeleton for job list items
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            SkeletonLoader(
              width: double.infinity,
              height: 20,
              margin: const EdgeInsets.only(bottom: 12),
            ),

            // Company + salary row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SkeletonLoader(
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ),
                Expanded(flex: 1, child: SkeletonLoader(height: 16)),
              ],
            ),
            const SizedBox(height: 12),

            // Description skeleton (2 lines)
            SkeletonLoader(
              width: double.infinity,
              height: 16,
              margin: const EdgeInsets.only(bottom: 8),
            ),
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton for list of jobs
class JobListSkeleton extends StatelessWidget {
  final int itemCount;

  const JobListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const JobCardSkeleton(),
    );
  }
}

/// Pre-built skeleton for user profile
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: SkeletonLoader(
              width: 80,
              height: 80,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ),

          // Name
          Center(
            child: SkeletonLoader(
              width: 150,
              height: 20,
              margin: const EdgeInsets.only(bottom: 12),
            ),
          ),

          // Email
          Center(
            child: SkeletonLoader(
              width: 180,
              height: 16,
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),

          // Bio title
          SkeletonLoader(
            width: 100,
            height: 18,
            margin: const EdgeInsets.only(bottom: 12),
          ),

          // Bio text (3 lines)
          ...List.generate(
            3,
            (index) => SkeletonLoader(
              width: double.infinity,
              height: 14,
              margin: const EdgeInsets.only(bottom: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-built skeleton for detail view
class DetailViewSkeleton extends StatelessWidget {
  const DetailViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section (wide title)
            SkeletonLoader(
              width: double.infinity,
              height: 28,
              margin: const EdgeInsets.only(bottom: 16),
            ),

            // Metadata row
            Row(
              children: [
                Expanded(
                  child: SkeletonLoader(
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ),
                Expanded(child: SkeletonLoader(height: 16)),
              ],
            ),
            const SizedBox(height: 24),

            // Body section title
            SkeletonLoader(
              width: 120,
              height: 20,
              margin: const EdgeInsets.only(bottom: 12),
            ),

            // Body paragraph (4 lines)
            ...List.generate(
              4,
              (index) => SkeletonLoader(
                width: double.infinity,
                height: 16,
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ),

            const SizedBox(height: 24),

            // Action button
            SkeletonLoader(
              width: double.infinity,
              height: 44,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
