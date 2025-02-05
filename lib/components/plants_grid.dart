import 'package:flutter/material.dart';

class PlantsGrid extends StatelessWidget {
  const PlantsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 104,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Image(
                    image: AssetImage("../assets/images/cherry.png"),
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 0, width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(49, 228, 161, 85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Fruits",
                          style: TextStyle(
                            color: Color.fromARGB(255, 246, 125, 3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Text("Cherry Plant",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const Text("120 plants",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
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
