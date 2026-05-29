import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shown when Firebase is not yet configured.
class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const setupSteps = '''
1. Create a Firebase project at console.firebase.google.com
2. Enable Anonymous Auth, Firestore, Storage, Functions
3. Run: dart pub global activate flutterfire_cli
4. Run: flutterfire configure
5. Run app with:
   flutter run --dart-define=FIREBASE_CONFIGURED=true
''';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Firebase Setup Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (message != null)
                Text(
                  message!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    setupSteps,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(
                      text:
                          'flutter run --dart-define=FIREBASE_CONFIGURED=true',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Run command copied')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy run command'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
