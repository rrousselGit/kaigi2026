import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// A port of canvas-confetti's default burst.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => ConfettiState();
}

class ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Color(0xFF26CCFF),
    Color(0xFFA25AFD),
    Color(0xFFFF5E7E),
    Color(0xFF88FF5A),
    Color(0xFFFCFF42),
    Color(0xFFFFA62D),
    Color(0xFFFF36FF),
  ];
  static const _ticks = 200;

  final _random = Random();
  final _particles = <_Particle>[];
  late final Ticker _ticker = createTicker(_onTick);
  var _lastTick = 0;

  /// Fires a burst of particles from 60% of the screen height.
  void fire({int count = 100, double spread = 70}) {
    for (var i = 0; i < count; i++) {
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * spread * pi / 180;
      _particles.add(
        _Particle(
          color: _colors[_random.nextInt(_colors.length)],
          angle: angle,
          velocity: 45 * 0.5 + _random.nextDouble() * 45,
          wobble: _random.nextDouble() * 10,
          wobbleSpeed: min(0.11, _random.nextDouble() * 0.1 + 0.05),
          tiltAngle: (_random.nextDouble() * 0.5 + 0.25) * pi,
          drift: (_random.nextDouble() - 0.5) * 2,
        ),
      );
    }
    if (!_ticker.isActive) {
      _lastTick = 0;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final tick = elapsed.inMicroseconds * 60 ~/ Duration.microsecondsPerSecond;
    for (; _lastTick < tick; _lastTick++) {
      for (final particle in _particles) {
        particle.step();
      }
      _particles.removeWhere((particle) => particle.tick >= _ticks);
    }
    if (_particles.isEmpty) _ticker.stop();
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_particles, _ticks),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.color,
    required this.angle,
    required this.velocity,
    required this.wobble,
    required this.wobbleSpeed,
    required this.tiltAngle,
    required this.drift,
  });

  final Color color;
  final double angle;
  final double wobbleSpeed;
  final double drift;
  double velocity;
  double wobble;
  double tiltAngle;
  double x = 0;
  double y = 0;
  int tick = 0;

  void step() {
    x += cos(angle) * velocity + drift;
    y += sin(angle) * velocity + 3;
    velocity *= 0.9;
    wobble += wobbleSpeed;
    tiltAngle += 0.1;
    tick++;
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.ticks);

  final List<_Particle> particles;
  final int ticks;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.6);
    final paint = Paint();
    for (final particle in particles) {
      final center = origin + Offset(particle.x, particle.y);
      final wobbleX = 10 * cos(particle.wobble);
      final wobbleY = 10 * sin(particle.wobble);
      final tilt = sin(particle.tiltAngle);
      paint.color = particle.color.withValues(alpha: 1 - particle.tick / ticks);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + wobbleX, center.dy + tilt * 4)
        ..lineTo(center.dx + wobbleX + tilt * 4, center.dy + wobbleY)
        ..lineTo(center.dx + tilt * 4, center.dy + wobbleY)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
