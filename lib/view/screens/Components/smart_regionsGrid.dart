import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/Components/SmartRegionCard.dart';

class SmartRegionsGrid extends StatelessWidget {
  const SmartRegionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartRegionsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    int calculateCrossAxisCount() {
      if (screenWidth >= 1200) {
        return 4;
      } else if (screenWidth >= 800) {
        return 3;
      } else {
        return 2;
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: calculateCrossAxisCount(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.99,
          ),
          itemCount: provider.cardsData.length,
          itemBuilder: (context, index) {
            final card = provider.cardsData[index];
            return SmartRegionCard(
              icon: card["icon"],
              iconColor: card["iconColor"],
              title: card["title"],
              subtitle: card["subtitle"],
              switchValue: provider.switches[index],
              onSwitchChanged: (newValue) {
                provider.toggleSwitch(index, newValue);
              },
            );
          },
        ),
      ),
    );
  }
}
