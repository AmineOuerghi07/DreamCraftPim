import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/land_service.dart';


class LandViewModel extends ChangeNotifier {
  final LandService _landService = LandService();
  ApiResponse<List<Land>> _landsResponse = ApiResponse.initial('Fetching lands...');
  List<Land> _lands = [];

  ApiResponse<List<Land>> get landsResponse => _landsResponse;
  List<Land> get lands => _lands;

  ApiResponse<Land> _landResponse = ApiResponse.initial('');
  ApiResponse<Land> get landResponse => _landResponse;

  ApiResponse<Land> _addLandResponse = ApiResponse.initial('');
  ApiResponse<Land> get addLandResponse => _addLandResponse;
  
  LandViewModel() {
    fetchLands();
  }



Future<ApiResponse> addLand({
  required Land land,
  required File image,
}) async {
  _addLandResponse = ApiResponse.loading('Adding land...');
  notifyListeners();

  try {
    final response = await _landService.addLand(land: land, image: image);

    if (response.status == Status.COMPLETED) {
      _addLandResponse = ApiResponse.completed(response.data!);
      await fetchLands();
      return ApiResponse.completed(response.data!); // return successful response
    } else {
      _addLandResponse = ApiResponse.error(response.message ?? 'Failed to add land');
      return ApiResponse.error(response.message ?? 'Failed to add land'); // return error response
    }
  } catch (e) {
    _addLandResponse = ApiResponse.error('Error adding land: ${e.toString()}');
    return ApiResponse.error('Error adding land: ${e.toString()}'); // return error response
  } finally {
    notifyListeners();
  }
}


   Future<void> fetchLandById(String id) async {
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
  }
  
 Future<void> deleteLand(String id) async {
  try {
    _landResponse = ApiResponse.loading('Deleting...');
    notifyListeners();
    
    final response = await _landService.deleteLand(id);
    if (response.status == Status.COMPLETED) {
      // Clear cached data
      _landResponse = ApiResponse.initial('Land deleted');
      // Remove from lands list
      _lands.removeWhere((land) => land.id == id);
      fetchLands();
    } else {
      _landResponse = ApiResponse.error(response.message ?? 'Delete failed');
    }
  } catch (e) {
    _landResponse = ApiResponse.error('Delete error: $e');
  }finally{notifyListeners();
  }
  
}

  Future<ApiResponse> updateLand(String id, Land updatedLand,{File? image}) async {
    try {
      _landResponse = ApiResponse.loading('Updating...');
      notifyListeners();
      
      final response = await _landService.updateLand(id, updatedLand,image: image);
      if (response.status == Status.COMPLETED) {
       return _landResponse = ApiResponse.completed(response.data);
      } else {
      return  _landResponse = ApiResponse.error(response.message ?? 'Update failed');
      }
    } catch (e) {
      return _landResponse = ApiResponse.error('Update error: $e');
    }finally {
    notifyListeners();
  }
   
  }


Future<void> fetchLands() async {
  _landsResponse = ApiResponse.loading('Fetching lands...');
  notifyListeners();

  try {
    final response = await _landService.getLands();
    print('Service Response: ${response.status} - ${response.data}');

    if (response.status == Status.COMPLETED && response.data != null) {
      _lands = response.data!;
      _landsResponse = ApiResponse.completed(_lands);
    } else {
      _landsResponse = ApiResponse.error(response.message ?? 'Unknown error');
    }
  } catch (e, stack) {
    print('Fetch Error: $e\n$stack');
    _landsResponse = ApiResponse.error('Failed to fetch lands: ${e.toString()}');
  }

  notifyListeners();
}

}