import 'package:flutter/foundation.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/region_service.dart';
import 'package:pim_project/model/services/api_client.dart'; // For ApiResponse and Status

class ConnectedRegionViewModel extends ChangeNotifier {
  final RegionService _regionService = RegionService();
  List<Region> _connectedRegions = [];
  Status _status = Status.INITIAL;
  String? _message;
  bool _noRegionsFound = false; // New flag to track 404 errors specifically

  List<Region> get connectedRegions => _connectedRegions;
  Status get status => _status;
  String? get message => _message;
  bool get noRegionsFound => _noRegionsFound; // Getter for the new flag

  Future<void> fetchConnectedRegions(String userId) async {
    try {
      _status = Status.LOADING;
      _message = 'Loading connected regions...';
      _noRegionsFound = false; // Reset the flag
      notifyListeners();

      final response = await _regionService.findConnectedRegions(userId);
      print('API Response for regions: $response'); // Debug log

      switch (response.status) {
        case Status.COMPLETED:
          _connectedRegions = response.data ?? [];
          _message = null;
          _status = Status.COMPLETED;
          break;
        case Status.ERROR:
          _connectedRegions = [];
          _message = response.message ?? 'Failed to load connected regions';
          _status = Status.ERROR;
          
          // Check if the error message indicates no regions found (404)
          if (response.message?.contains('No lands found') == true || 
              response.statusCode == 404) {
            _noRegionsFound = true;
            _status = Status.COMPLETED; // Change to COMPLETED so we show "No regions" UI
          }
          break;
        default:
          _message = 'Unexpected response status';
          _status = Status.ERROR;
      }
    } catch (e) {
      _status = Status.ERROR;
      _message = 'An error occurred: $e';
      _connectedRegions = [];
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _status = Status.INITIAL;
    _message = null;
    _connectedRegions = [];
    _noRegionsFound = false;
    notifyListeners();
  }
}