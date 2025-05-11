// lib/widgets/plant_loading_animation.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppProgressIndicator extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final double size;
  final String? loadingText;
  
  const AppProgressIndicator({
    Key? key,
    this.primaryColor = const Color(0xFF4CAF50), // Green
    this.secondaryColor = const Color(0xFF8BC34A), // Light Green
    this.size = 120.0,
    this.loadingText,
  }) : super(key: key);

  @override
  State<AppProgressIndicator> createState() => _AppProgressIndicatorAnimationState();
}

class _AppProgressIndicatorAnimationState extends State<AppProgressIndicator> 
       with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _growAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Animation for growing plant
    _growAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    // Animation for slight rotation (swaying)
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Animation for leaves appearing
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              height: widget.size,
              width: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soil
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: widget.size * 0.12,
                      width: widget.size * 0.6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF795548), // Brown
                        borderRadius: BorderRadius.all(Radius.circular(widget.size * 0.06)),
                      ),
                    ),
                  ),
                  
                  // Plant stem
                  Positioned(
                    bottom: widget.size * 0.1,
                    child: Transform.rotate(
                      angle: math.sin(_controller.value * 2 * math.pi) * 0.05,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: _growAnimation.value * widget.size * 0.55,
                        width: widget.size * 0.05,
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.circular(widget.size * 0.025),
                        ),
                      ),
                    ),
                  ),

                  // Create symmetrical leaves on both sides
                  // First pair - bottom
                  ..._buildLeafPair(
                    bottom: widget.size * 0.25,
                    width: widget.size * 0.22,
                    stemOffset: widget.size * 0.15,
                    angle: 0.6,
                  ),
                  
                  // Second pair - middle
                  ..._buildLeafPair(
                    bottom: widget.size * 0.4,
                    width: widget.size * 0.18,
                    stemOffset: widget.size * 0.12,
                    angle: 0.4,
                  ),
                  
                  // Third pair - top
                  ..._buildLeafPair(
                    bottom: widget.size * 0.53,
                    width: widget.size * 0.14,
                    stemOffset: widget.size * 0.09,
                    angle: 0.3,
                  ),
                  
                  // Top leaf/bud
                  Positioned(
                    bottom: widget.size * 0.63 - (_growAnimation.value * 2),
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        alignment: Alignment.bottomCenter,
                        child: _buildTopLeaf(),
                      ),
                    ),
                  ),
                  
                  // Water drops animation
                  ...List.generate(3, (index) {
                    final delay = index * 0.3;
                    final dropPosition = ((_controller.value + delay) % 1.0);
                    
                    if (dropPosition < 0.7) {
                      return Positioned(
                        top: dropPosition * widget.size,
                        left: widget.size * 0.3 + (index * 10),
                        child: Opacity(
                          opacity: 1.0 - (dropPosition / 0.7),
                          child: Container(
                            height: widget.size * 0.05,
                            width: widget.size * 0.05,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
                ],
              ),
            );
          },
        ),
        
        // Optional loading text
        if (widget.loadingText != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.loadingText!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]
      ],
    );
  }
  
  // Helper method to create a symmetrical pair of leaves
  List<Widget> _buildLeafPair({
    required double bottom,
    required double width,
    required double stemOffset,
    required double angle,
  }) {
    return [
      // Left leaf
      Positioned(
        bottom: bottom,
        right: widget.size * 0.40 + stemOffset,
        child: Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.rotate(
            angle: -angle + (_rotateAnimation.value * 0.1),
            alignment: Alignment.centerRight,
            child: _buildLeaf(width, widget.secondaryColor, isLeftLeaf: true),
          ),
        ),
      ),
      
      // Right leaf
      Positioned(
        bottom: bottom,
        left: widget.size * 0.40 + stemOffset,
        child: Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.rotate(
            angle: angle + (_rotateAnimation.value * 0.1),
            alignment: Alignment.centerLeft,
            child: _buildLeaf(width, widget.secondaryColor, isLeftLeaf: false),
          ),
        ),
      ),
    ];
  }

  // Helper method to build the top leaf/bud
  Widget _buildTopLeaf() {
    return Container(
      width: widget.size * 0.12,
      height: widget.size * 0.18,
      decoration: BoxDecoration(
        color: widget.primaryColor,
        borderRadius: BorderRadius.circular(widget.size * 0.06),
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.06,
          height: widget.size * 0.12,
          decoration: BoxDecoration(
            color: widget.secondaryColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(widget.size * 0.03),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaf(double width, Color color, {required bool isLeftLeaf}) {
    return CustomPaint(
      size: Size(width, width * 0.6),
      painter: LeafPainter(color, isLeftLeaf: isLeftLeaf),
    );
  }
}

// Custom painter for drawing leaf shape
class LeafPainter extends CustomPainter {
  final Color color;
  final bool isLeftLeaf;
  
  LeafPainter(this.color, {required this.isLeftLeaf});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    if (isLeftLeaf) {
      // Left leaf shape
      path.moveTo(size.width, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.3, 0, 
        0, size.height * 0.5
      );
      path.quadraticBezierTo(
        size.width * 0.3, size.height, 
        size.width, size.height * 0.5
      );
    } else {
      // Right leaf shape
      path.moveTo(0, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.7, 0, 
        size.width, size.height * 0.5
      );
      path.quadraticBezierTo(
        size.width * 0.7, size.height, 
        0, size.height * 0.5
      );
    }
    
    path.close();
    canvas.drawPath(path, paint);
    
    // Add a stem line in the middle of the leaf
    final stemPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    
    final stemPath = Path();
    if (isLeftLeaf) {
      stemPath.moveTo(size.width, size.height * 0.5);
      stemPath.quadraticBezierTo(
        size.width * 0.5, size.height * 0.5,
        size.width * 0.2, size.height * 0.5
      );
    } else {
      stemPath.moveTo(0, size.height * 0.5);
      stemPath.quadraticBezierTo(
        size.width * 0.5, size.height * 0.5,
        size.width * 0.8, size.height * 0.5
      );
    }
    
    canvas.drawPath(stemPath, stemPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}