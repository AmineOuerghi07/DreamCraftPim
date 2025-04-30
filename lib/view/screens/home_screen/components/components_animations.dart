import 'dart:math' as math;

import 'package:flutter/material.dart';

class SunAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const SunAnimation({
    Key? key,
    this.size = 100.0,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  _SunAnimationState createState() => _SunAnimationState();
}

class _SunAnimationState extends State<SunAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CloudAnimation extends StatefulWidget {
  final double size;
  final bool isDark;

  const CloudAnimation({
    Key? key,
    this.size = 100.0,
    this.isDark = false,
  }) : super(key: key);

  @override
  _CloudAnimationState createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<CloudAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0.0),
      end: const Offset(0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: CustomPaint(
        size: Size(widget.size, widget.size * 0.6),
        painter: CloudPainter(isDark: widget.isDark),
      ),
    );
  }
}

class CloudPainter extends CustomPainter {
  final bool isDark;

  CloudPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.grey[700]! : Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.5,
        size.width * 0.1,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.3,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.1,
        size.width * 0.7,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.2,
        size.width * 0.9,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.5,
      )
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RainDropsAnimation extends StatefulWidget {
  const RainDropsAnimation({Key? key}) : super(key: key);

  @override
  _RainDropsAnimationState createState() => _RainDropsAnimationState();
}

class _RainDropsAnimationState extends State<RainDropsAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int numberOfDrops = 10;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      numberOfDrops,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 100)),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(numberOfDrops, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: (index * 10).toDouble(),
              top: _animations[index].value * 100,
              child: Container(
                width: 2,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class SnowflakesAnimation extends StatefulWidget {
  const SnowflakesAnimation({Key? key}) : super(key: key);

  @override
  _SnowflakesAnimationState createState() => _SnowflakesAnimationState();
}

class _SnowflakesAnimationState extends State<SnowflakesAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int numberOfFlakes = 10;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      numberOfFlakes,
      (index) => AnimationController(
        duration: Duration(milliseconds: 2000 + (index * 200)),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(numberOfFlakes, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: (index * 10).toDouble(),
              top: _animations[index].value * 100,
              child: Transform.rotate(
                angle: _animations[index].value * 2 * math.pi,
                child: Icon(
                  Icons.ac_unit,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class MoonAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const MoonAnimation({
    Key? key,
    this.size = 100.0,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  _MoonAnimationState createState() => _MoonAnimationState();
}

class _MoonAnimationState extends State<MoonAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: MoonPainter(
              glowValue: _glowAnimation.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class MoonPainter extends CustomPainter {
  final double glowValue;
  final Color color;

  MoonPainter({
    required this.glowValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dessiner le cercle principal de la lune
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Ajouter l'effet de lueur
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(glowValue * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}