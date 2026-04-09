import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/job_platform_theme.dart';
import 'routes/app_router.dart';
import 'presentation/providers/app_providers.dart';

void main() => runApp(
      MultiProvider(
        providers: AppProviders.providers,
        child: const JobPlatformApp(),
      ),
    );

class JobPlatformApp extends StatelessWidget {
  const JobPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;

    return MaterialApp.router(
      title: 'Job Platform',
      theme: JobPlatformTheme.light,
      darkTheme: JobPlatformTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
