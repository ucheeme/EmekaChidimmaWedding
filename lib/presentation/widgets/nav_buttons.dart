import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_paths.dart';
import '../cubit/music/music_cubit.dart';

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

/// Play/pause toggle for the background music. Renders nothing when no track is
/// configured, so screens without music stay visually unchanged.
class MusicToggleButton extends StatelessWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, MusicState>(
      buildWhen: (p, c) => p.hasTrack != c.hasTrack || p.playing != c.playing,
      builder: (context, state) {
        if (!state.hasTrack) return const SizedBox.shrink();
        return IconButton(
          icon: Icon(state.playing ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          tooltip: state.playing ? 'Mute music' : 'Play music',
          onPressed: () => context.read<MusicCubit>().toggle(),
        );
      },
    );
  }
}
