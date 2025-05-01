import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';

class WeatherApiService {
  static const String baseUrl = '${AppConstants.baseUrl}/weather';

  Future<Map<String, dynamic>?> getWeatherByCoordinates(double latitude, double longitude) async {
    try {
      print('🌤️ [WeatherService] Récupération des données météo pour les coordonnées: $latitude, $longitude');
      final url = Uri.parse('$baseUrl/coordinates?lat=$latitude&lon=$longitude');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 [WeatherService] Status code: ${response.statusCode}');
      print('📡 [WeatherService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Aucune donnée météo reçue');
        }
        return data;
      } else {
        throw Exception('Erreur: Statut ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [WeatherService] Erreur: $e');
      throw Exception('Erreur lors de la récupération des données météo: ${e.toString()}');
    }
  }
}