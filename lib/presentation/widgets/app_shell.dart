import 'package:flutter/material.dart';

import 'offline_banner.dart';

/// Wraps routed content with global chrome (offline banner).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}
