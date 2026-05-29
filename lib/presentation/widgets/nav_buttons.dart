import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';

/// Back button that pops when there is a stack to pop, and otherwise routes to
/// home. This prevents dead ends when a screen is opened via a stack-replacing
/// navigation or a deep link, where [BuildContext.pop] would have nothing to
/// pop.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      tooltip: 'Back',
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.home);
        }
      },
    );
  }
}

/// Quick jump to the home hub from any screen in the experience.
class HomeIconButton extends StatelessWidget {
  const HomeIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home_rounded),
      tooltip: 'Home',
      onPressed: () => context.go(RoutePaths.home),
    );
  }
}
