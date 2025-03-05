// view_model/add_plant_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/plant.dart';
import 'package:pim_project/model/services/plant_service.dart';
import 'package:pim_project/model/services/api_client.dart';

class AddPlantViewModel with ChangeNotifier {
  final PlantService _plantService = PlantService();
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];
  Map<String, int> _plantQuantities = {}; // Plant ID -> Quantity
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Plant> get filteredPlants => _filteredPlants;
  bool get isLoading => _isLoading;
  bool get hasSelectedPlants => _plantQuantities.values.any((q) => q > 0);

  int getQuantity(String plantId) => _plantQuantities[plantId] ?? 0;

  AddPlantViewModel() {
    loadPlants();
  }

  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _plantService.getPlants();
      if (response.status == Status.COMPLETED && response.data != null) {
        _allPlants = response.data!;
        _filteredPlants = _allPlants;
        _plantQuantities = {for (var plant in _allPlants) plant.id: 0};
      } else {
        _filteredPlants = [];
      }
    } catch (e) {
      _filteredPlants = [];
      print('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPlants(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredPlants = _allPlants;
    } else {
      _filteredPlants = _allPlants
          .where((plant) => plant.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void incrementQuantity(String plantId) {
    _plantQuantities[plantId] = (_plantQuantities[plantId] ?? 0) + 1;
    notifyListeners();
  }

  void decrementQuantity(String plantId) {
    final currentQuantity = _plantQuantities[plantId] ?? 0;
    if (currentQuantity > 0) {
      _plantQuantities[plantId] = currentQuantity - 1;
      notifyListeners();
    }
  }

  Map<String, int> getSelectedPlants() {
    return Map.fromEntries(
      _plantQuantities.entries.where((entry) => entry.value > 0),
    );
  }
}