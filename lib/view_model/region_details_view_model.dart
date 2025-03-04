import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/plant.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/plant_service.dart';
import 'package:pim_project/model/services/region_service.dart';

class RegionDetailsViewModel with ChangeNotifier {
  final PlantService _plantService = PlantService();
  final RegionService _regionService = RegionService();
  
  ApiResponse<List<Plant>> _plantResponse = ApiResponse.initial('Fetching land details...');
  ApiResponse<Region>? _regionResponse;
  
  List<Plant> _plants = [];
  Region? _region;
  bool _isLoading = false;
  String? _errorMessage;

  // Map to store the selected quantity for each plant (key: plant id)
  final Map<String, int> _plantQuantities = {};

  // Getters
  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Region? get region => _region;

  // Returns the current quantity for a plant (default 0)
  int getQuantity(String plantId) => _plantQuantities[plantId] ?? 0;

  // Increase quantity for a plant
  void incrementQuantity(String plantId) {
    _plantQuantities[plantId] = getQuantity(plantId) + 1;
    notifyListeners();
  }

  // Decrease quantity for a plant (min: 0)
  void decrementQuantity(String plantId) {
    if (getQuantity(plantId) > 0) {
      _plantQuantities[plantId] = getQuantity(plantId) - 1;
      notifyListeners();
    }
  }

  Future<void> getRegionById(String regionId) async {
    _regionResponse = ApiResponse.loading('Fetching region...');
    notifyListeners();

    try {
      final response = await _regionService.getRegionsById(regionId);
      if (response.status == Status.COMPLETED && response.data != null) {
        _region = response.data!;
        _regionResponse = ApiResponse.completed(response.data!);
      } else {
        _regionResponse = ApiResponse.error(response.message ?? 'Failed to fetch region');
      }
    } catch (e) {
      _regionResponse = ApiResponse.error('An error occurred: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<ApiResponse<Region>> addPlantToRegion(Region region, String plant) async {
    _isLoading = true;
    notifyListeners();

    try {
      region.plants.add(plant); // adds the plant to the region

      final response = await _regionService.updateRegion(region);

      if (response.status == Status.COMPLETED && response.data != null) {
        return ApiResponse.completed(response.data);
      } else {
        _errorMessage = response.message ?? 'Failed to update region';
        return ApiResponse.error(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      return ApiResponse.error(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load plants and initialize their quantities to 0
  Future<void> loadPlants() async {
    _isLoading = true;
    _plants = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _plantService.getPlants();
      
      if (response.status == Status.COMPLETED && response.data != null) {
        _plants = response.data!;
        _plantResponse = ApiResponse.completed(_plants);
        // Initialize each plant's counter to 0
        for (var plant in _plants) {
          _plantQuantities[plant.id] = 0;
        }
      } else {
        _errorMessage = response.message ?? 'Failed to load plants';
        _plantResponse = ApiResponse.error(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _plantResponse = ApiResponse.error(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSelectedPlantsToRegion(String regionId) async {
  _isLoading = true;
  notifyListeners();
  try {
    for (var entry in _plantQuantities.entries) {
      final plantId = entry.key;
      final qty = entry.value;
      if (qty > 0) {
        await _regionService.addPlantToRegion(regionId, plantId, qty);
      }
    }
    // Optionally refresh the region data after adding plants
    await getRegionById(regionId);
  } catch (e) {
    _errorMessage = 'Failed to add plants: ${e.toString()}';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}
