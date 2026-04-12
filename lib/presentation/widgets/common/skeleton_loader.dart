// lib/presentation/widgets/common/skeleton_loader.dart
// ─────────────────────────────────────────────────────────────────────────────
// Animated skeleton loader for professional loading states
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a job card (list item)
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 20, width: 200),
            const SizedBox(height: 12),
            SkeletonLoader(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            SkeletonLoader(height: 16, width: 250),
            const SizedBox(height: 12),
            Row(
              children: [
                SkeletonLoader(height: 12, width: 80),
                const SizedBox(width: 16),
                SkeletonLoader(height: 12, width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Build a list of skeleton loaders
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function()? itemBuilder;

  const SkeletonList({super.key, this.itemCount = 5, this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder?.call() ?? const JobCardSkeleton();
      },
    );
  }
}
