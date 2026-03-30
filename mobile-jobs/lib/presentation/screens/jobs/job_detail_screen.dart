import 'package:flutter/material.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: const Center(child: Text('Job Detail Screen - To be implemented')),
    );
  }
}
