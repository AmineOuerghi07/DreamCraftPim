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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            painter: ArcPaint(),
            child: SizedBox(
              height: size.height / 1.35,
              width: size.width,
            ),
          ),
          Positioned(
            top: 110,
            right: 0,
            left: 0,
            child: Lottie.network(
              onboardingItems[currentIndex].lottieURL,
              width: 500,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error), // Handle invalid URL
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 270,
              child: Column(
                children: [
                  Flexible(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: onboardingItems.length,
                      itemBuilder: (context, index) {
                        final item = onboardingItems[index];
                        return Column(
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        );
                      },
                      onPageChanged: (value) {
                        setState(() {
                          currentIndex = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < onboardingItems.length; index++)
                        dotIndicator(isSelected: index == currentIndex),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentIndex < onboardingItems.length - 1) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.linear,
            );
          } else {
            GoRouter.of(context).go('/login');
          }
        },
        elevation: 0,
        backgroundColor: Colors.white,
        child: Icon(
          currentIndex < onboardingItems.length - 1
              ? Icons.arrow_forward_ios
              : Icons.check,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget dotIndicator({required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: isSelected ? 8 : 6,
        width: isSelected ? 8 : 6,
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
    Path orangeArc = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 175)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 175)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(orangeArc, Paint()..color = const Color.fromARGB(255, 14, 139, 9));

    Path whiteArc = Path()
      ..moveTo(0.0, 0.0)
      ..lineTo(0.0, size.height - 180)
      ..quadraticBezierTo(size.width / 2, size.height - 60, size.width, size.height - 180)
      ..lineTo(size.width, size.height)
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