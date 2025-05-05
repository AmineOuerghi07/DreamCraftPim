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
    final isTablet = screenWidth >= 600;

    // Improved initialization logic to ensure proper state synchronization
    // This runs on every build, but with efficient checks to minimize unnecessary updates
    if (provider.isAutomaticMode != irrigationViewModel.isAutomaticMode || 
        !_areControlsSynchronized(provider, irrigationViewModel)) {
      // Force full synchronization
      provider.setIrrigationViewModel(irrigationViewModel);
      
      // Ensure system status is up-to-date
      Future.microtask(() => irrigationViewModel.getSystemStatus());
    }

    int calculateCrossAxisCount() {
      if (screenWidth >= 1200) {
        return 4; // Large tablets and desktop
      } else if (screenWidth >= 800) {
        return 3; // Medium tablets like Nokia T20
      } else if (screenWidth >= 600) {
        return 2; // Small tablets and large phones
      } else {
        return 2; // Phones like Huawei P30 Pro
      }
    }

    return Container(
      color: Colors.white, // Ensure the container has a white background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Enhanced Mode Switch
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16.0 : 12.0,
              horizontal: isTablet ? 16.0 : 8.0,
            ),
            child: Column(
              children: [
                Text(
                  'Control Mode',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF204D4F),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Manual mode
                      _buildModeButton(
                        context,
                        'Manual',
                        !provider.isAutomaticMode,
                        () => provider.setOperationMode(false),
                        Icons.handyman,
                        isTablet,
                      ),
                      // Automatic mode
                      _buildModeButton(
                        context,
                        'Automatic',
                        provider.isAutomaticMode,
                        () => provider.setOperationMode(true),
                        Icons.auto_fix_high,
                        isTablet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.isAutomaticMode 
                      ? 'System will automatically adjust settings based on environmental conditions'
                      : 'You have full control over all system settings',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Cards grid
          Expanded(
            child: Container(
              color: Colors.white, // Ensure the scrollable area has a white background
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 8.0 : 4.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(),
                      crossAxisSpacing: isTablet ? 12 : 8,
                      mainAxisSpacing: isTablet ? 12 : 8,
                      childAspectRatio: isTablet ? 1.0 : 0.95,
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
                          highlightLevel = value == null
                              ? HighlightLevel.normal
                              : value < 15
                                  ? HighlightLevel.normal
                                  : value < 20
                                      ? HighlightLevel.medium
                                      : HighlightLevel.danger;
                          break;
                        case "Temperature":
                          highlightLevel = value == null
                              ? HighlightLevel.normal
                              : value < 30
                                  ? HighlightLevel.normal
                                  : value < 37
                                      ? HighlightLevel.medium
                                      : HighlightLevel.danger;
                          break;
                        case "Irrigation":
                          highlightLevel = value == null
                              ? HighlightLevel.normal
                              : value < 150
                                  ? HighlightLevel.normal
                                  : value < 250
                                      ? HighlightLevel.medium
                                      : HighlightLevel.danger;
                          break;
                        case "Ventilator":
                          highlightLevel = HighlightLevel.normal;
                          break;
                        default:
                          highlightLevel = HighlightLevel.normal;
                      }

                      bool isDisabled = provider.isAutomaticMode && 
                          (title == "Temperature" || title == "Irrigation" || title == "Ventilator");

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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, 
    String label, 
    bool isActive, 
    VoidCallback onTap,
    IconData icon,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF204D4F) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isActive 
              ? null 
              : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 22 : 18,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if all controls are properly synchronized
  bool _areControlsSynchronized(SmartRegionsProvider provider, IrrigationViewModel viewModel) {
    return provider.switches[0] == viewModel.isLedOn &&
           provider.switches[1] == viewModel.isTemperatureSensorOn &&
           provider.switches[2] == viewModel.isPumpOn &&
           provider.switches[3] == viewModel.isVentilatorOn;
  }
}