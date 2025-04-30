// view/screens/components/smart_regionsGrid.dart
import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/SmartRegionsProvider.dart';
import 'package:pim_project/model/domain/highlight_level.dart';
import 'package:pim_project/view_model/irrigation_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view/screens/Components/SmartRegionCard.dart';

class SmartRegionsGrid extends StatelessWidget {
  const SmartRegionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartRegionsProvider>(context);
    final irrigationViewModel = Provider.of<IrrigationViewModel>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;

    // Connect the irrigation view model to the provider if not already done
    if (provider.isAutomaticMode != irrigationViewModel.isAutomaticMode) {
      provider.setIrrigationViewModel(irrigationViewModel);
    }

    int calculateCrossAxisCount() {
      if (screenWidth >= 1200) {
        return 4;
      } else if (screenWidth >= 800) {
        return 3;
      } else {
        return 2;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode Switch at the top
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mode:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Manual mode
                      GestureDetector(
                        onTap: () => provider.setOperationMode(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: !provider.isAutomaticMode
                                ? const Color(0xFF204D4F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Manual',
                            style: TextStyle(
                              color: !provider.isAutomaticMode
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Automatic mode
                      GestureDetector(
                        onTap: () => provider.setOperationMode(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: provider.isAutomaticMode
                                ? const Color(0xFF204D4F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Automatic',
                            style: TextStyle(
                              color: provider.isAutomaticMode
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Smart cards grid
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: calculateCrossAxisCount(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.97,
              ),
              itemCount: provider.cardsData.length,
              itemBuilder: (context, index) {
                final card = provider.cardsData[index];
                final title = card["title"] as String;
                final subtitle = card["subtitle"] as String;
                HighlightLevel highlightLevel;

                // Extract numeric value from subtitle (if present)
                final match = RegExp(r'\d+(\.\d+)?').firstMatch(subtitle);
                final value = match != null ? double.tryParse(match.group(0)!) : null;

                // Define thresholds based on sensor type (title)
                switch (title) {
                  case "Lighting":
                    // Example: wattage thresholds
                    highlightLevel = value == null
                        ? HighlightLevel.normal
                        : value < 15
                            ? HighlightLevel.normal
                            : value < 20
                                ? HighlightLevel.medium
                                : HighlightLevel.danger;
                    break;
                  case "Temperature":
                    // Example: temperature thresholds (°C)
                    highlightLevel = value == null
                        ? HighlightLevel.normal
                        : value < 30
                            ? HighlightLevel.normal
                            : value < 37
                                ? HighlightLevel.medium
                                : HighlightLevel.danger;
                    break;
                  case "Irrigation":
                    // Example: meter thresholds (assuming 'm' means meters)
                    highlightLevel = value == null
                        ? HighlightLevel.normal
                        : value < 150
                            ? HighlightLevel.normal
                            : value < 250
                                ? HighlightLevel.medium
                                : HighlightLevel.danger;
                    break;
                  case "Soil":
                    // Non-numeric case: Define based on subtitle text
                    highlightLevel = subtitle == "Growth"
                        ? HighlightLevel.normal
                        : HighlightLevel.medium; // Example logic
                    break;
                  default:
                    highlightLevel = HighlightLevel.normal;
                }

                // Determine if card should be disabled in automatic mode
                // Only temperature and irrigation cards should be disabled
                bool isDisabled = provider.isAutomaticMode && 
                    (title == "Temperature" || title == "Irrigation");

                return SmartRegionCard(
                  icon: card["icon"],
                  iconColor: card["iconColor"],
                  title: card["title"],
                  subtitle: card["subtitle"],
                  switchValue: provider.switches[index],
                  onSwitchChanged: (newValue) {
                    provider.toggleSwitch(index, newValue);
                  },
                  highlightLevel: highlightLevel,
                  isDisabled: isDisabled,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}