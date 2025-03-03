import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/land_service.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/region_service.dart';

class LandDetailsViewModel with ChangeNotifier {
  final LandService _landService = LandService();
  final RegionService _regionService = RegionService();
  ApiResponse<Land> _landResponse = ApiResponse.initial('Fetching land details...');
  ApiResponse<Land> get landResponse => _landResponse;
 ApiResponse<List<Region>> _regionsResponse = ApiResponse.initial('Fetching regions...');
  ApiResponse<List<Region>> get regionsResponse => _regionsResponse;

  Land? _land;
  Land? get land => _land;
 List<Region> _regions = [];
  List<Region> get regions => _regions;

   
  Future<void> fetchRegionsForLand(String landId) async {
    _regionsResponse = ApiResponse.loading('Loading regions...');
    notifyListeners();

    try {
      // Step 1: Fetch the land by its ID
      final landResponse = await _landService.getLandById(landId);
      if (landResponse.status != Status.COMPLETED || landResponse.data == null) {
        throw Exception('Failed to fetch land: ${landResponse.message}');
      }

      final land = landResponse.data!;

      // Step 2: Extract the list of region IDs from the land
      final List<String> regionIds = land.regions;

      // Step 3: Fetch the full details for each region ID
      final List<Region> fetchedRegions = [];
      for (final regionId in regionIds) {
        final regionResponse = await _regionService.getRegionsById(regionId);
        if (regionResponse.status == Status.COMPLETED && regionResponse.data != null) {
          fetchedRegions.add(regionResponse.data!);
        }
      }

      // Update the regions list
      _regions = fetchedRegions;
      _regionsResponse = ApiResponse.completed(_regions);
    } catch (e) {
      _regionsResponse = ApiResponse.error('Failed to fetch regions: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }
  Future<ApiResponse<Land>> fetchLandById(String id) async {
    _landResponse = ApiResponse.loading('Fetching land details...');
    notifyListeners();

    try {
      final response = await _landService.getLandById(id);
      if (response.status == Status.COMPLETED && response.data != null) {
        _land = response.data!;
        return _landResponse = ApiResponse.completed(_land!);
      } else {
       return _landResponse = ApiResponse.error(response.message ?? 'Unknown error');
      }
    } catch (e) {
    return  _landResponse = ApiResponse.error('Failed to fetch land: ${e.toString()}');
    }finally{
    notifyListeners();

    }

  }

  Future<ApiResponse<Land>> updateLand(Land updatedLand, {File? image}) async {
    _landResponse = ApiResponse.loading('Updating...');
    notifyListeners();

    try {
      final response = await _landService.updateLand(updatedLand.id, updatedLand, image: image);
      if (response.status == Status.COMPLETED) {
        _land = response.data!;
      return  _landResponse = ApiResponse.completed(_land!);
      } else {
      return  _landResponse = ApiResponse.error(response.message ?? 'Update failed');
      }
    } catch (e) {
    return  _landResponse = ApiResponse.error('Update error: $e');
    }finally{
    notifyListeners();

    }

  }
   Future<ApiResponse> deleteLand(String id) async {
    _landResponse = ApiResponse.loading('Deleting...');
    notifyListeners();

    try {
      final response = await _landService.deleteLand(id);
      if (response.status == Status.COMPLETED) {
        _landResponse = ApiResponse.initial('Land deleted');
        _land = null; // Since it's deleted, remove reference
      } else {
        _landResponse = ApiResponse.error(response.message ?? 'Delete failed');
      }
    } catch (e) {
      _landResponse = ApiResponse.error('Delete error: $e');
    } finally {
      notifyListeners();
    }
    return _landResponse;
  }

Future<ApiResponse<Region>> addRegion(Region region) async {
  try {
    print('Adding region: ${region.toJson()}'); // Add logging
    final response = await _regionService.addRegion(region);
    print('Response: ${response.status} - ${response.message}');
    
    if (response.status == Status.COMPLETED) {
      await fetchLandById(region.land);
    }
    return response;
  } catch (e) {
    print('Error adding region: $e'); // Add error logging
    return ApiResponse.error('Failed to add region: ${e.toString()}');
  } finally {
    notifyListeners();
  }
}
 Future<ApiResponse<List<Region>>> fetchAllRegions() async {
    _regionsResponse = ApiResponse.loading('Fetching all regions...');
    notifyListeners();

    try {
      final response = await _regionService.getRegions();
      if (response.status == Status.COMPLETED) {
        _regions = response.data!;
        _regionsResponse = ApiResponse.completed(_regions);
      } else {
        _regionsResponse = ApiResponse.error(response.message ?? 'Error fetching regions');
      }
    } catch (e) {
      _regionsResponse = ApiResponse.error('Fetch error: $e');
    } finally {
      notifyListeners();
    }

    return _regionsResponse;
  }
}
