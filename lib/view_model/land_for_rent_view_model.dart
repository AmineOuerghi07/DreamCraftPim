import 'package:flutter/foundation.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/services/land_service.dart';
import 'package:pim_project/model/services/api_client.dart'; // For ApiResponse and Status

class LandForRentViewModel extends ChangeNotifier {
  final LandService _landService = LandService();
  List<Land> _landsForRent = [];
  Status _status = Status.INITIAL;
  String? _message;


  List<Land> get landsForRent => _landsForRent;
  Status get status => _status;
  String? get message => _message;

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
          print('Lands for Rent: $_landsForRent'); // Debug log
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

  void reset() {
    _status = Status.INITIAL;
    _message = null;
    _landsForRent = [];
    notifyListeners();
  }
}