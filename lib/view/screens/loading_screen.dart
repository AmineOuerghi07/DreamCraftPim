import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const LoadingScreen({Key? key, this.arguments}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer l'état précédent
      final previousState = widget.arguments?['previousState'] as String?;
      
      if (previousState == 'language_change') {
        // Si c'est un changement de langue, retourner à la page précédente
        if (mounted) {
          context.pop();
        }
        return;
      }
      
      // Vérifier si l'utilisateur est connecté
      final userId = await prefs.getString('user_id');
      final token = await prefs.getString('token');
      final rememberMe = await prefs.getBool('remember_me') ?? false;
      
      // Attendre un court délai pour montrer l'animation
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        if (rememberMe && userId != null && token != null) {
          // L'utilisateur est connecté, rediriger vers l'écran d'accueil
          context.go(RouteNames.home);
        } else {
          // L'utilisateur n'est pas connecté, rediriger vers l'écran de connexion
          context.go(RouteNames.login);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'initialisation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoadingAnimationScreen extends StatefulWidget {
  const LoadingAnimationScreen({Key? key}) : super(key: key);

  @override
  _LoadingAnimationScreenState createState() => _LoadingAnimationScreenState();
}

class _LoadingAnimationScreenState extends State<LoadingAnimationScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;
  final List<MicrobeParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _particles.add(MicrobeParticle());
    }
    
    // Start particle animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateParticles();
    });
  }

  void _animateParticles() {
    for (var particle in _particles) {
      particle.reset();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 20,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Leaf base
                  CustomPaint(
                    painter: LeafPainter(),
                  ),
                  
                  // Scanning effect
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return ClipPath(
                        clipper: ScanClipper(_scanAnimation.value),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Floating particles
                  for (var particle in _particles)
                    AnimatedPositioned(
                      duration: particle.duration,
                      left: particle.x,
                      top: particle.y,
                      child: Container(
                        width: particle.size,
                        height: particle.size,
                        decoration: BoxDecoration(
                          color: particle.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Analyzing Leaf Structure...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Detecting potential diseases',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.4, 0)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.2, 
                         size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.7, 
                         size.width * 0.4, size.height)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.7, 
                         0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.1, size.height * 0.3, 
                         size.width * 0.4, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ScanClipper extends CustomClipper<Path> {
  final double progress;

  ScanClipper(this.progress);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTRB(
        0,
        size.height * progress - 20,
        size.width,
        size.height * progress + 20,
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class MicrobeParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  Color color = Colors.transparent;
  Duration duration = Duration.zero;

  MicrobeParticle() {
    reset();
  }

  void reset() {
    x = Random().nextDouble() * 200;
    y = Random().nextDouble() * 200;
    size = Random().nextDouble() * 4 + 2;
    color = Colors.primaries[Random().nextInt(Colors.primaries.length)]
        .withOpacity(0.6);
    duration = Duration(milliseconds: 4000 + Random().nextInt(2000));
  }
}