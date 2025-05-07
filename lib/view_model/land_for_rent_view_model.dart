// view_model/land_for_rent_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/land_service.dart';
import 'package:pim_project/model/services/api_client.dart'; // For ApiResponse and Status
import 'package:pim_project/constants/constants.dart';

class LandForRentViewModel extends ChangeNotifier {
  final LandService _landService = LandService();
  final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  List<Land> _landsForRent = [];
  Status _status = Status.INITIAL;
  String? _message;
  Land? _selectedLand;

  List<Land> get landsForRent => _landsForRent;
  Status get status => _status;
  String? get message => _message;
  Land? get selectedLand => _selectedLand;

  Future<void> fetchLandsForRent() async {
    try {
      _status = Status.LOADING;
      _message = 'Loading lands for rent...';
      notifyListeners();

      final response = await _landService.findLandsForRent();
      print('API Response for lands: $response'); // Debug log

      switch (response.status) {
        case Status.COMPLETED:
          _landsForRent = response.data ?? [];
          print('Lands for Rent count: ${_landsForRent.length}'); // Debug log
          
          // Debug: print all land ids to help with debugging
          if (_landsForRent.isNotEmpty) {
            print('Land IDs: ${_landsForRent.map((land) => land.id).join(', ')}');
            // Debug first land's details
            print('First land details: ${_landsForRent.first.name}, ${_landsForRent.first.surface}m², '
                  'Owner ID: ${_landsForRent.first.userId}, '
                  'For rent: ${_landsForRent.first.forRent}, '
                  'Price: ${_landsForRent.first.rentPrice}');
          }
          
          // Fetch owner details for lands that have a userId
          await _fetchOwnerDetails();
          
          _message = null;
          _status = Status.COMPLETED;
          break;
        case Status.ERROR:
          _landsForRent = [];
          _message = response.message ?? 'Failed to load lands for rent';
          _status = Status.ERROR;
          break;
        default:
          _message = 'Unexpected response status';
          _status = Status.ERROR;
      }
    } catch (e) {
      _status = Status.ERROR;
      _message = 'An error occurred: $e';
      _landsForRent = [];
    } finally {
      notifyListeners();
    }
  }

  // Fetch owner details for each land
  Future<void> _fetchOwnerDetails() async {
    try {
      for (int i = 0; i < _landsForRent.length; i++) {
        final land = _landsForRent[i];
        // Only fetch if we have a userId and don't already have the owner details
        if (land.userId.isNotEmpty && land.owner == null) {
          try {
            // Use the correct endpoint to fetch user details
            final response = await _apiClient.get(
              'account/get-account/${land.userId}',
              (json) => User.fromJson(json),
            );
            
            if (response.status == Status.COMPLETED && response.data != null) {
              // Get phone from either the phonenumber or phone field
              final phoneNumber = response.data!.phonenumber.isNotEmpty 
                  ? response.data!.phonenumber 
                  : response.data!.phone;
                  
              // Update the land with the owner information
              _landsForRent[i] = land.copyWith(
                owner: response.data,
                ownerPhone: phoneNumber,
              );
              
              print('Fetched owner details for land ${land.name}: ${response.data!.fullname}, Phone: $phoneNumber');
            }
          } catch (e) {
            print('Error fetching owner for land ${land.name}: $e');
          }
        }
      }
    } catch (e) {
      print('Error in _fetchOwnerDetails: $e');
    }
    // Notify listeners of updated data
    notifyListeners();
  }

  Future<void> fetchLandDetails(String landId) async {
    try {
      _status = Status.LOADING;
      _message = 'Loading land details...';
      notifyListeners();

      // First check if the land is already in our list
      Land? foundLand;
      try {
        foundLand = _landsForRent.firstWhere(
          (land) => land.id == landId,
        );
        
        _selectedLand = foundLand;
        _status = Status.COMPLETED;
        _message = null;
        notifyListeners();
        return;
            } catch (e) {
        print('Land not found in local list: $e');
      }

      // If not found in the list, fetch it from the API
      final response = await _landService.getLandById(landId);
      
      switch (response.status) {
        case Status.COMPLETED:
          _selectedLand = response.data;
          
          // Debug the returned land data
          if (_selectedLand != null) {
            print('Fetched land details for ID $landId: '
                  '${_selectedLand!.name}, ${_selectedLand!.surface}m², '
                  'Owner ID: ${_selectedLand!.userId}, '
                  'For rent: ${_selectedLand!.forRent}, '
                  'Price: ${_selectedLand!.rentPrice}');
            
            // Fetch owner details if we have a userId
            if (_selectedLand!.userId.isNotEmpty && _selectedLand!.owner == null) {
              try {
                final userResponse = await _apiClient.get(
                  'account/get-account/${_selectedLand!.userId}',
                  (json) => User.fromJson(json),
                );
                
                if (userResponse.status == Status.COMPLETED && userResponse.data != null) {
                  // Get phone from either the phonenumber or phone field
                  final phoneNumber = userResponse.data!.phonenumber.isNotEmpty 
                      ? userResponse.data!.phonenumber 
                      : userResponse.data!.phone;
                      
                  // Update the land with the owner information
                  _selectedLand = _selectedLand!.copyWith(
                    owner: userResponse.data,
                    ownerPhone: phoneNumber,
                  );
                  print('Fetched owner details: ${userResponse.data!.fullname}, Phone: $phoneNumber');
                }
              } catch (e) {
                print('Error fetching owner details: $e');
              }
            }
          } else {
            print('Received null land from API for ID $landId');
          }
          
          _status = Status.COMPLETED;
          _message = null;
          break;
        case Status.ERROR:
          _selectedLand = null;
          _message = response.message ?? 'Failed to load land details';
          _status = Status.ERROR;
          break;
        default:
          _message = 'Unexpected response status';
          _status = Status.ERROR;
      }
    } catch (e) {
      _status = Status.ERROR;
      _message = 'An error occurred: $e';
      _selectedLand = null;
      print('Exception in fetchLandDetails: $e');
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _status = Status.INITIAL;
    _message = null;
    _landsForRent = [];
    _selectedLand = null;
    notifyListeners();
  }
}