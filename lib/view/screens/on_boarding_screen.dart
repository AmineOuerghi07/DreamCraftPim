import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String lottieURL;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.lottieURL,
  });
}

final List<OnboardingItem> onboardingItems = [
  OnboardingItem(
    title: "Smart Farming Begins",
    subtitle: "Use IoT and drones to monitor your crops with ease.",
    lottieURL: "https://lottie.host/ecde07a8-b9a4-49a5-a3b0-d43ab7d6d6ff/SStCOi8Xbn.json" // IoT Digital Farming with Drone
  ),
  OnboardingItem(
    title: "Explore Your Land",
    subtitle: "Navigate and manage your fields effortlessly.",
    lottieURL: "https://lottie.host/1c04dfba-a6ad-4d08-94e2-1b224dbb2f8d/rrWiLa3LNg.json"
  ),
  OnboardingItem(
    title: "Stay Connected",
    subtitle: "Get real-time updates and connect with your farm.",
    lottieURL: "https://lottie.host/1c8db494-493d-4434-b33f-7510caaccd3a/WdfUDiPAyR.json"
  ),
];

class AnimatedOnboardingScreen extends StatefulWidget {
  const AnimatedOnboardingScreen({super.key});

  @override
  State<AnimatedOnboardingScreen> createState() => _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive dimensions
          final double arcHeight = constraints.maxHeight * 0.75;
          final double lottieTopPosition = constraints.maxHeight * 0.12;
          final double lottieWidth = isTablet 
              ? constraints.maxWidth * 0.6 
              : constraints.maxWidth * 0.85;
          final double textSectionHeight = constraints.maxHeight * 0.3;
          
          return Stack(
            children: [
              // Background arc
              CustomPaint(
                painter: ArcPaint(),
                size: Size(constraints.maxWidth, arcHeight),
              ),
              
              // Lottie animation
              Positioned(
                top: lottieTopPosition,
                right: 0,
                left: 0,
                child: Lottie.network(
                  onboardingItems[currentIndex].lottieURL,
                  width: lottieWidth,
                  height: constraints.maxHeight * 0.4,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.error, size: 50), // Handle invalid URL
                ),
              ),
              
              // Bottom text section
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: textSectionHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Page content
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: onboardingItems.length,
                          itemBuilder: (context, index) {
                            final item = onboardingItems[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: constraints.maxWidth * 0.08,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 36 : 28,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: constraints.maxHeight * 0.04),
                                  Text(
                                    item.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isTablet ? 22 : 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onPageChanged: (value) {
                            setState(() {
                              currentIndex = value;
                            });
                          },
                        ),
                      ),
                      
                      // Dot indicators
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: constraints.maxHeight * 0.03,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int index = 0; index < onboardingItems.length; index++)
                              dotIndicator(
                                isSelected: index == currentIndex,
                                size: isTablet ? 10.0 : 8.0,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final double fabSize = isTablet ? 64.0 : 56.0;
          final double iconSize = isTablet ? 28.0 : 24.0;
          
          return SizedBox(
            width: fabSize,
            height: fabSize,
            child: FloatingActionButton(
              onPressed: () {
                if (currentIndex < onboardingItems.length - 1) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  GoRouter.of(context).go('/login');
                }
              },
              elevation: 2,
              backgroundColor: Colors.white,
              child: Icon(
                currentIndex < onboardingItems.length - 1
                    ? Icons.arrow_forward_ios
                    : Icons.check,
                color: Colors.black,
                size: iconSize,
              ),
            ),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget dotIndicator({required bool isSelected, double size = 8.0}) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: isSelected ? size : size * 0.75,
        width: isSelected ? size : size * 0.75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.black26,
        ),
      ),
    );
  }
}

class ArcPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate dynamic curve heights based on screen size
    final double curveHeight1 = size.height * 0.15;
    final double curveHeight2 = size.height * 0.12;
    
    // First curve (darker green)
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - curveHeight1)
      ..quadraticBezierTo(
          size.width / 2, 
          size.height, 
          size.width, 
          size.height - curveHeight1)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(orangeArc, Paint()..color = const Color.fromARGB(255, 14, 139, 9));

    // Second curve (light blue)
    Path whiteArc = Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, size.height - curveHeight2 - 5)
      ..quadraticBezierTo(
          size.width / 2, 
          size.height - curveHeight2 / 3, 
          size.width, 
          size.height - curveHeight2 - 5)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      whiteArc,
      Paint()..color = const Color.fromARGB(255, 144, 202, 249),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}