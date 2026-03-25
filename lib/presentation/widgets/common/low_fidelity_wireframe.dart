import 'package:flutter/material.dart';

import 'package:portfolioph/core/constants/app_constants.dart';

/// Reusable low-fidelity wireframe primitives for early UI planning.
class WireframeBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const WireframeBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class WireframeSectionTitle extends StatelessWidget {
  final String title;

  const WireframeSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class WireframeTile extends StatelessWidget {
  final double height;

  const WireframeTile({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: const [
          WireframeBox(height: 24, width: 24),
          SizedBox(width: AppConstants.spacingMd),
          Expanded(child: WireframeBox(height: 12)),
          SizedBox(width: AppConstants.spacingMd),
          WireframeBox(height: 16, width: 16),
        ],
      ),
    );
  }
}
