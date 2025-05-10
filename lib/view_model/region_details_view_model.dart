import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/plant.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/land_service.dart';
import 'package:pim_project/model/services/plant_service.dart';
import 'package:pim_project/model/services/region_service.dart';
import 'package:pim_project/view_model/land_details_view_model.dart';

class RegionDetailsViewModel with ChangeNotifier {
  final PlantService _plantService = PlantService();
  final RegionService _regionService = RegionService();
  final LandService _landService = LandService();

  ApiResponse<List<Plant>> _plantResponse = ApiResponse.initial('Fetching land details...');
  ApiResponse<Region>? _regionResponse;
  ApiResponse<Land>? _landResponse; // Added for land data
  ApiResponse<Region>? get regionResponse => _regionResponse; // Public getter for _regionResponse
  ApiResponse<Land>? get landResponse => _landResponse;

  List<Plant> _plants = [];
  Region? _region;
  Land? _land; // Added to store land data
  bool _isLoading = false;
  String? _errorMessage;

  // Map to store the selected quantity for each plant (key: plant id)
  final Map<String, int> _plantQuantities = {};

  // Getters
  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Region? get region => _region;
  Land? get land => _land; // Added getter for land

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
        // Fetch land data after getting the region
        await getLandById(_region!.land.id);
      } else {
        _regionResponse = ApiResponse.error(response.message ?? 'Failed to fetch region');
      }
    } catch (e) {
      _regionResponse = ApiResponse.error('An error occurred: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<void> getLandById(String landId) async {
    _landResponse = ApiResponse.loading('Fetching land...');
    notifyListeners();

    try {
      final response = await _landService.getLandById(landId); // Assuming this exists in LandService
      if (response.status == Status.COMPLETED && response.data != null) {
        _land = response.data!;
        _landResponse = ApiResponse.completed(response.data!);
      } else {
        _landResponse = ApiResponse.error(response.message ?? 'Failed to fetch land');
      }
    } catch (e) {
      _landResponse = ApiResponse.error('An error occurred: ${e.toString()}');
    } finally {
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

 Future<void> addSelectedPlantsToRegion(String regionId, {Map<String, int>? selectedPlants}) async {
  _isLoading = true;
  notifyListeners();
  try {
    // Use the provided selectedPlants, or fall back to _plantQuantities if none provided
    final plantsToAdd = selectedPlants ?? _plantQuantities;
    for (var entry in plantsToAdd.entries) {
      final plantId = entry.key;
      final qty = entry.value;
      if (qty > 0) {
        await _regionService.addPlantToRegion(regionId, plantId, qty);
      }
    }
    // Refresh region data after adding plants
    LandDetailsViewModel landDetailsViewModel = LandDetailsViewModel(region?.land.id ?? ''); 
   await  landDetailsViewModel.fetchPlantsForLand(region!.land.id);
       await getRegionById(regionId);
  } catch (e) {
    _errorMessage = 'Failed to add plants: ${e.toString()}';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<ApiResponse<Region>> updateRegion(Region updatedRegion) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _regionService.updateRegion(updatedRegion);
      if (response.status == Status.COMPLETED && response.data != null) {
        _region = response.data!;
        _regionResponse = ApiResponse.completed(_region!);
        return ApiResponse.completed(_region!);
      } else {
        _errorMessage = response.message ?? 'Failed to update region';
        return ApiResponse.error(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'Update error: ${e.toString()}';
      return ApiResponse.error(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to delete a region
 Future<ApiResponse<void>> deleteRegion(String regionId) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _regionService.deleteRegion(regionId);
    if (response.status == Status.COMPLETED) {
      // Store landId before clearing region data
      final landId = _region?.land.id;
      
      // Clear region data after deletion
      _region = null;
      _regionResponse = null;
      
      // If we have the parent land's ID, we can refresh its data too
      if (landId != null) {
        try {
          // Create a new instance to avoid circular dependencies
          LandDetailsViewModel landViewModel = LandDetailsViewModel(landId);
          await landViewModel.fetchRegionsForLand(landId);
          await landViewModel.fetchPlantsForLand(landId);
        } catch (e) {
          print("Error refreshing land data: $e");
          // Continue with deletion even if refresh fails
        }
      }
      
      return ApiResponse.completed(null);
    } else {
      _errorMessage = response.message ?? 'Failed to delete region';
      return ApiResponse.error(_errorMessage!);
    }
  } catch (e) {
    _errorMessage = 'Delete error: ${e.toString()}';
    return ApiResponse.error(_errorMessage!);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}