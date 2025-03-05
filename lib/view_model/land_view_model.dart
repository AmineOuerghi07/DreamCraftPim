import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/land_service.dart';

class LandViewModel extends ChangeNotifier {
  final LandService _landService = LandService();
  ApiResponse<List<Land>> _landsResponse = ApiResponse.initial('Fetching lands...');
  List<Land> _lands = [];
  List<Land> _filteredLands = []; // New: Filtered list for search
  String _searchQuery = ''; // New: Store the search query

  ApiResponse<List<Land>> get landsResponse => _landsResponse;
  List<Land> get lands => _lands;
  List<Land> get filteredLands => _filteredLands; // New getter for filtered lands

  ApiResponse<Land> _landResponse = ApiResponse.initial('');
  ApiResponse<Land> get landResponse => _landResponse;

  ApiResponse<Land> _addLandResponse = ApiResponse.initial('');
  ApiResponse<Land> get addLandResponse => _addLandResponse;

  LandViewModel() {
    fetchLands();
  }

  Future<ApiResponse<List<Land>>> fetchLands() async {
    _landsResponse = ApiResponse.loading('Fetching lands...');
    _lands = [];
    _filteredLands = []; // Reset filtered lands
    notifyListeners();

    try {
      final response = await _landService.getLands();
      print('Service Response: ${response.status} - ${response.data}');

      if (response.status == Status.COMPLETED && response.data != null) {
        _lands = response.data!;
        _filteredLands = _lands; // Initially, filtered lands = all lands
        _landsResponse = ApiResponse.completed(_lands);
      } else {
        _landsResponse = ApiResponse.error(response.message ?? 'Unknown error');
      }
    } catch (e, stack) {
      print('Fetch Error: $e\n$stack');
      _landsResponse = ApiResponse.error('Failed to fetch lands: ${e.toString()}');
    } finally {
      notifyListeners();
    }

    return _landsResponse;
  }

  Future<ApiResponse<Land>> fetchLandById(String id) async {
    _landResponse = ApiResponse.loading('Fetching land details...');
    notifyListeners();

    try {
      final response = await _landService.getLandById(id);
      if (response.status == Status.COMPLETED && response.data != null) {
        _landResponse = ApiResponse.completed(response.data!);
      } else {
        _landResponse = ApiResponse.error(response.message ?? 'Unknown error');
      }
    } catch (e) {
      _landResponse = ApiResponse.error('Failed to fetch land: ${e.toString()}');
    }

    notifyListeners();
    return _landResponse;
  }

  Future<ApiResponse> addLand({required Land land, required File image}) async {
    _addLandResponse = ApiResponse.loading('Adding land...');
    notifyListeners();

    try {
      final response = await _landService.addLand(land: land, image: image);

      if (response.status == Status.COMPLETED) {
        _addLandResponse = ApiResponse.completed(response.data!);
        await fetchLands(); // Refetch lands and reset filtered list
      } else {
        _addLandResponse = ApiResponse.error(response.message ?? 'Failed to add land');
      }
    } catch (e) {
      _addLandResponse = ApiResponse.error('Error adding land: ${e.toString()}');
    } finally {
      notifyListeners();
    }
    return _addLandResponse;
  }

  // New: Method to update search query and filter lands
  void searchLands(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredLands = _lands; // Show all lands if query is empty
    } else {
      _filteredLands = _lands.where((land) {
        return land.name.toLowerCase().contains(_searchQuery) ||
               land.cordonate.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    notifyListeners(); // Notify UI to rebuild with filtered lands
  }
}