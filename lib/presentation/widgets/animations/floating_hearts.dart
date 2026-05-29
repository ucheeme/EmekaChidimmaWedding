import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Soft floating heart particles.
class FloatingHearts extends StatefulWidget {
  const FloatingHearts({super.key, this.count = 12});

  final int count;

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_HeartParticle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _particles = List.generate(widget.count, (_) {
      return _HeartParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 8 + _random.nextDouble() * 14,
        speed: 0.3 + _random.nextDouble() * 0.7,
        phase: _random.nextDouble() * pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _HeartsPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _HeartParticle {
  _HeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });

  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
}

class _HeartsPainter extends CustomPainter {
  _HeartsPainter({required this.particles, required this.progress});

  final List<_HeartParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dy = (p.y - progress * p.speed) % 1.0;
      final dx = p.x + sin(progress * 2 * pi + p.phase) * 0.02;
      final opacity = 0.15 + sin(progress * pi + p.phase).abs() * 0.25;

      final paint = Paint()
        ..color = AppColors.roseGold.withValues(alpha: opacity * 0.8);

      final center = Offset(dx * size.width, dy * size.height);
      _drawHeart(canvas, center, p.size, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.3)
      ..cubicTo(
        center.dx - size,
        center.dy - size * 0.5,
        center.dx - size * 0.5,
        center.dy - size,
        center.dx,
        center.dy - size * 0.3,
      )
      ..cubicTo(
        center.dx + size * 0.5,
        center.dy - size,
        center.dx + size,
        center.dy - size * 0.5,
        center.dx,
        center.dy + size * 0.3,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
