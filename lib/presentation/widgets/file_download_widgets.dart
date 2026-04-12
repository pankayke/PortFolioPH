// lib/presentation/widgets/file_download_widgets.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets for file downloads and progress indication.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';

/// A button that triggers file download with progress indication
class DownloadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData icon;
  final Color? color;

  const DownloadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.download,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Colors.white,
                ),
              ),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey[300],
      ),
    );
  }
}

/// A card showing download progress
class DownloadProgressCard extends StatelessWidget {
  final String title;
  final FileDownloadProvider provider;
  final VoidCallback onDismiss;

  const DownloadProgressCard({
    super.key,
    required this.title,
    required this.provider,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: provider.downloadProgress,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(provider.downloadProgress * 100).toStringAsFixed(0)}% '
              '(${_formatBytes(provider.downloadedBytes)} / ${_formatBytes(provider.totalBytes)})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Dialog for downloading files with format selection
class DownloadDialog extends StatefulWidget {
  final String title;
  final String? description;
  final List<String> formats;
  final Function(String format) onDownload;

  const DownloadDialog({
    super.key,
    required this.title,
    this.description,
    required this.formats,
    required this.onDownload,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  late String _selectedFormat;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.formats.first;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileDownloadProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isDownloading;

        return AlertDialog(
          title: Text(widget.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(widget.description!),
                ),
              Text(
                'Select format:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.formats.map((format) {
                  return ChoiceChip(
                    label: Text(format.toUpperCase()),
                    selected: _selectedFormat == format,
                    onSelected: isLoading
                        ? null
                        : (_) => setState(() => _selectedFormat = format),
                  );
                }).toList(growable: false),
              ),
              if (provider.isDownloading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: provider.downloadProgress,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(provider.downloadProgress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Error: ${provider.errorMessage}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () {
                widget.onDownload(_selectedFormat);
              },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Download'),
            ),
          ],
        );
      },
    );
  }
}

/// Export options menu for admin
class ExportMenu extends StatelessWidget {
  final String title;
  final VoidCallback onExcelPressed;
  final VoidCallback onCSVPressed;

  const ExportMenu({
    super.key,
    required this.title,
    required this.onExcelPressed,
    required this.onCSVPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'excel') {
          onExcelPressed();
        } else if (value == 'csv') {
          onCSVPressed();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'excel',
          child: Row(
            children: const [
              Icon(Icons.table_chart, size: 20),
              SizedBox(width: 8),
              Text('Export as Excel'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'csv',
          child: Row(
            children: const [
              Icon(Icons.description, size: 20),
              SizedBox(width: 8),
              Text('Export as CSV'),
            ],
          ),
        ),
      ],
      child: Tooltip(
        message: title,
        child: const Icon(Icons.download_sharp),
      ),
    );
  }
}
