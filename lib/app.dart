import 'package:flutter/material.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/app_bloc_providers.dart';
import 'presentation/widgets/app_shell.dart';

class ForeverMomentsApp extends StatelessWidget {
  const ForeverMomentsApp({super.key, required this.firebase});

  final FirebaseBootstrapResult firebase;

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter(firebase: firebase);

    return AppBlocProviders(
      firebase: firebase,
      child: MaterialApp.router(
        title: 'Forever Moments',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => AppShell(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
