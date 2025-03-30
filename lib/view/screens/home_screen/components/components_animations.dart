import 'dart:math';

import 'package:flutter/material.dart';

class RainDropsAnimation extends StatefulWidget {
  const RainDropsAnimation({Key? key}) : super(key: key);

  @override
  _RainDropsAnimationState createState() => _RainDropsAnimationState();
}

class _RainDropsAnimationState extends State<RainDropsAnimation> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  final int _rainDropsCount = 8;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _rainDropsCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + _random.nextInt(400)),
        vsync: this,
      )
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _random.nextInt(500)), () {
        if (mounted) {
          _controllers[i].repeat(); // Use repeat instead of forward
        }
      });
    }
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
      children: List.generate(_rainDropsCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: 3.0 + (index % 4) * 6.0,
              top: _animations[index].value * 24.0 - 4.0,
              child: Opacity(
                opacity: 1.0 - _animations[index].value * 0.5,
                child: Container(
                  width: 1.5,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
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
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fallAnimations;
  late final List<Animation<double>> _swayAnimations;
  final int _snowflakesCount = 6;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _snowflakesCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + _random.nextInt(500)),
        vsync: this,
      )
    );

    _fallAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    }).toList();

    _swayAnimations = _controllers.map((controller) {
      return Tween<double>(begin: -1.0, end: 1.0)
          .animate(CurvedAnimation(
              parent: controller, curve: Curves.easeInOutSine));
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: _random.nextInt(500)), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
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
      children: List.generate(_snowflakesCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned(
              left: 5.0 + (index % 3) * 8.0 + _swayAnimations[index].value * 3.0,
              top: _fallAnimations[index].value * 24.0 - 4.0,
              child: Opacity(
                opacity: 1.0 - _fallAnimations[index].value * 0.3,
                child: Container(
                  width: 3.0,
                  height: 3.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}