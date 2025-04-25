import 'package:http/http.dart' as http;
import 'dart:convert';

class HumidityService {
 // static const String baseUrl = 'http://192.168.43.232:3000/weather/humidity-details';
  static const String baseUrl = 'http://127.0.0.1:3000/weather/humidity-details';



  Future<Map<String, dynamic>> getHumidityDetails(String city) async {
    final url = Uri.parse('$baseUrl?city=$city');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Erreur: Statut ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }

  Future<Map<String, dynamic>> getHumidityByCoordinates(double latitude, double longitude) async {
    final url = Uri.parse('$baseUrl?lat=$latitude&lon=$longitude');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Erreur: Statut ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }
}
