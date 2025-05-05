import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pim_project/constants/constants.dart';

class HumidityService {
  static const String baseUrl = '${AppConstants.baseUrl}/weather/humidity-details/coordinates';

  Future<Map<String, dynamic>> getHumidityByCoordinates(double latitude, double longitude) async {
    try {
      print('🌡️ [HumidityService] Récupération des données d\'humidité pour les coordonnées: $latitude, $longitude');
      final url = Uri.parse('$baseUrl?lat=$latitude&lon=$longitude');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 [HumidityService] Status code: ${response.statusCode}');
      print('📡 [HumidityService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Aucune donnée d\'humidité reçue');
        }
        return data;
      } else {
        throw Exception('Erreur: Statut ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ [HumidityService] Erreur: $e');
      throw Exception('Erreur lors de la récupération des données d\'humidité: ${e.toString()}');
    }
  }
}