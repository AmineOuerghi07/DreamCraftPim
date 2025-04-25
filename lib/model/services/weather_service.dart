import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApiService {
 // static const String baseUrl = 'http://192.168.43.232:3000/weather';
   static const String baseUrl = 'http://127.0.0.1:3000/weather';



  Future<Map<String, dynamic>?> getWeather(String city) async {
    final url = Uri.parse('$baseUrl?city=$city');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Tu obtiens ici : city, temperature, weather, humidity, advice (si calculé backend)
      } else {
        print('❌ Erreur ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur lors de la requête météo: $e');
      return null;
    }
  }
}
