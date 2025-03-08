import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pim_project/model/repositories/prediction_repository.dart';
import 'package:pim_project/model/services/api_client.dart';

class PredictionViewModel extends ChangeNotifier {
  final PredictionRepository _predictionRepository;

  PredictionViewModel({required PredictionRepository predictionRepository})
      : _predictionRepository = predictionRepository;

  bool _isLoading = false;
  String? _predictionResult;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get predictionResult => _predictionResult;
  String? get errorMessage => _errorMessage;

 Future<ApiResponse<String>> predictImage(File imageFile) async {
  _isLoading = true;
  _predictionResult = null;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _predictionRepository.predictImage(imageFile);
    if (response.status == Status.COMPLETED) {
      _predictionResult = response.data;
    } else {
      _errorMessage = response.message;
    }
    return response; // Return the response
  } catch (e) {
    _errorMessage = "Failed to process image.";
    return ApiResponse.error(_errorMessage!); // Return an error response
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}
