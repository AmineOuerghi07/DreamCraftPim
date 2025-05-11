// view/screens/add_plant_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/plant.dart';
import 'package:pim_project/view/screens/components/app_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/add_plant_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPlantScreen extends StatelessWidget {
  final String regionId;

  const AddPlantScreen({super.key, required this.regionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPlantViewModel(),
      child: Consumer<AddPlantViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              actions: [
                AnimatedOpacity(
                  opacity: viewModel.hasSelectedPlants ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextButton(
                      onPressed: viewModel.hasSelectedPlants
                          ? () {
                              final selectedPlants = viewModel.getSelectedPlants();
                              context.pop(selectedPlants); // Return selected plants
                            }
                          : null,
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: const TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onChanged: viewModel.searchPlants,
                  ),
                  const SizedBox(height: 16),
                  // Plant Grid
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child:  AppProgressIndicator(
  loadingText: 'Growing data...',
  primaryColor: const Color(0xFF4CAF50), // Green
  secondaryColor: const Color(0xFF8BC34A), // Light Green
  size: 75, // Controls the overall size
),)
                        : viewModel.filteredPlants.isEmpty
                            ? Center(child: Text(AppLocalizations.of(context)!.noPlantsFound))
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: viewModel.filteredPlants.length,
                                itemBuilder: (context, index) {
                                  final plant = viewModel.filteredPlants[index];
                                  return PlantCard(plant: plant);
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Plant Card Widget
class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPlantViewModel>(
      builder: (context, viewModel, child) {
        final quantity = viewModel.getQuantity(plant.id);
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: plant.imageUrl.isNotEmpty
                      ? Image.network(
                          AppConstants.imagesbaseURL + plant.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_florist, size: 50),
                        )
                      : const Icon(Icons.local_florist, size: 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  plant.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: quantity == 0
                        ? IconButton(
                            key: ValueKey('plus_${plant.id}'),
                            icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                            onPressed: () => viewModel.incrementQuantity(plant.id),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.red),
                                onPressed: () => viewModel.decrementQuantity(plant.id),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                                onPressed: () => viewModel.incrementQuantity(plant.id),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}