import 'package:flutter/material.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/land_request.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/land_request_service.dart';

class LandRequestViewModel with ChangeNotifier {
  final LandRequestService _landRequestService = LandRequestService();
  List<LandRequest> _landRequests = [];
  ApiResponse<List<LandRequest>> _landRequestsResponse =
      ApiResponse.initial('Fetching land requests...');
  ApiResponse<List<LandRequest>> get landRequestsResponse =>
      _landRequestsResponse;

  List<LandRequest> get landRequests => _landRequests;

  ApiResponse<LandRequest> _landRequestResponse = ApiResponse.initial('');

  ApiResponse<LandRequest> get landRequestResponse => _landRequestResponse;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<ApiResponse<List<LandRequest>>> fetchLandRequests(
      String userId) async {
    _isLoading = true;
    notifyListeners();
    final response = await _landRequestService.getLandRequests(userId);
    if (response.status == Status.COMPLETED) {
      _landRequests = response.data ?? [];
    } else {
      _landRequests = [];
    }
    _isLoading = false;
    notifyListeners();
    return _landRequestsResponse;
  }

  Future<ApiResponse<LandRequest>> addLandRequest(String landId) async {
    _landRequestsResponse = ApiResponse.loading('Adding land request...');
    _isLoading = true;
    notifyListeners();
    Map<String, String> request = {};
    request['requestingUser'] = MyApp.userId;
    request['landId'] = landId;
    try {
      final response = await _landRequestService.addLandRequest(request);
      if (response.status == Status.COMPLETED) {
        _landRequestResponse = ApiResponse.completed(response.data);
      } else {
        _landRequestResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _landRequestResponse =
          ApiResponse.error('Failed to add land request: ${e.toString()}');
    }
    _isLoading = false;
    notifyListeners();
    return _landRequestResponse;
  }

  Future<ApiResponse<LandRequest>> acceptLandRequest(String requestId) async {
    _landRequestResponse = ApiResponse.loading('Accepting land request...');
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _landRequestService.acceptLandRequest(requestId);
      if (response.status == Status.COMPLETED) {
        _landRequestResponse = ApiResponse.completed(response.data);
      } else {
        _landRequestResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _landRequestResponse =
          ApiResponse.error('Failed to accept land request: ${e.toString()}');
    }
    _isLoading = false;
    notifyListeners();
    return _landRequestResponse;
  }

  Future<ApiResponse<LandRequest>> rejectLandRequest(String requestId) async {
    _landRequestResponse = ApiResponse.loading('Rejecting land request...');
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _landRequestService.rejectLandRequest(requestId);
      if (response.status == Status.COMPLETED) {
        _landRequestResponse = ApiResponse.completed(response.data);
      } else {
        _landRequestResponse = ApiResponse.error(response.message);
      }
    } catch (e) {
      _landRequestResponse =
          ApiResponse.error('Failed to reject land request: ${e.toString()}');
    }
    _isLoading = false;
    notifyListeners();
    return _landRequestResponse;
  }

  dispose() {
    super.dispose();
  }
}
