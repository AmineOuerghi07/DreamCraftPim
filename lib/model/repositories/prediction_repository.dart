import 'dart:io';

import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/predection_service.dart';

class PredictionRepository {
  final PredictionService _predictionService;

  PredictionRepository({required PredictionService predictionService}) : _predictionService = predictionService;

  // Method to predict an image using the ApiClient
  Future<ApiResponse<String>> predictImage(File imageFile) async {
    return _predictionService.predictImage(imageFile);
  }
}