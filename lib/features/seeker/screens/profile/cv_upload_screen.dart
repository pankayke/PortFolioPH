import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/profile_provider.dart';

class CVUploadScreen extends StatefulWidget {
  const CVUploadScreen({super.key});

  @override
  State<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends State<CVUploadScreen> {
  File? _selectedFile;
  String? _selectedFileName;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) return;

    setState(() {
      _selectedFile = File(path);
      _selectedFileName = result.files.single.name;
    });
  }

  Future<void> _upload() async {
    final auth = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final user = auth.currentUser;

    if (user?.id == null || _selectedFile == null) return;

    if (profileProvider.currentProfile?.id != user!.id) {
      await profileProvider.loadProfile(user.id!);
    }

    try {
      final success = await profileProvider.updateProfile(
        resumeFile: _selectedFile,
      );

      if (!mounted) return;

      if (success && profileProvider.currentProfile != null) {
        auth.updateCurrentUser(profileProvider.currentProfile!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV uploaded successfully.')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileProvider.errorMessage ?? 'Failed to upload CV.',
            ),
          ),
        );
      }
    } on UnauthorizedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload CV')),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload your resume in PDF format.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('Max size is validated by the server.'),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: profileProvider.isLoading ? null : _pickPdf,
                        icon: const Icon(Icons.attach_file_outlined),
                        label: const Text('Select PDF File'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedFileName ?? 'No file selected',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: profileProvider.isLoading || _selectedFile == null
                              ? null
                              : _upload,
                          icon: profileProvider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_file_outlined),
                          label: const Text('Upload CV'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
