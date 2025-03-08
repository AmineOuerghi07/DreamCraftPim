// view_model/home_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/constants/constants.dart';
import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/region.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/constants/constants.dart';


class HomeViewModel with ChangeNotifier {
  List<Land> _rentedLands = [];
   List<Region> _connectedRegions = [];

  List<Land> get rentedLands => _rentedLands;
  List<Region> get connectedRegions => _connectedRegions;
  final apiClient = ApiClient(baseUrl: AppConstants.baseUrl);


  Future<void> fetchRentedLands(String userId) async {
  print('📤 Sending request with userId: $userId');

  final String url = '${AppConstants.baseUrl}/lands/users/$userId';
  final response = await http.get(Uri.parse(url));

  print('📜 Response Status: ${response.statusCode}');
  print('📜 Response Body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
     final dynamic data = jsonDecode(response.body);

      // Check if the response is a list
      if (data is List) {
        _rentedLands = data.map((json) => Land.fromJson(json)).toList();
      } else {
        throw Exception("Unexpected response format: ${response.body}");
      }

      notifyListeners();
    } else {
      throw Exception("Failed to load lands: ${response.statusCode}");
    }
  
  }
////////////////////////////
Future<void> fetchConnectedRegions(String userId) async {
  print('📤 Sending request with userId: $userId');

  final String url = '${AppConstants.baseUrl}/lands/region/users/$userId';
  final response = await http.get(Uri.parse(url));

  print('📜 Response Status: ${response.statusCode}');
  print('📜 Response Body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    List<dynamic> data = jsonDecode(response.body);
    _connectedRegions = data.map((json) => Region.fromJson(json)).toList();
    notifyListeners();
  } else {
    print('🔴 Error: Status Code ${response.statusCode}');
    throw Exception('Failed to load regions');
  }
}

}
