import 'package:flutter/material.dart';

/// Empty State Widget
///
/// Displays empty state UI with icon, title, and optional CTA
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final IconData? iconData;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconData,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              icon!
            else if (iconData != null)
              Icon(
                iconData,
                size: 64,
                color: Colors.grey.shade400,
              )
            else
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(buttonLabel!),
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

