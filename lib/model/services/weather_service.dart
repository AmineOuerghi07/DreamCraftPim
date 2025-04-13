import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:pim_project/constants/constants.dart';

class WeatherApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/weather';
  
  // Liste des villes supportées avec leurs coordonnées
  static const Map<String, Map<String, double>> supportedCities = {
    'Tunis': {'lat': 36.8065, 'lon': 10.1815},
    'Sfax': {'lat': 34.7452, 'lon': 10.7613},
    'Sousse': {'lat': 35.8245, 'lon': 10.6346},
    'Bizerte': {'lat': 37.2744, 'lon': 9.8739},
    'Gabes': {'lat': 33.8881, 'lon': 10.0972}
  };

  String _generatePesticideAdvice(Map<String, dynamic> weatherData) {
    final weather = weatherData['weather']?.toLowerCase() ?? '';
    final temperature = double.tryParse(weatherData['temperature']?.toString().replaceAll('°C', '') ?? '') ?? 0;
    final humidity = double.tryParse(weatherData['humidity']?.toString().replaceAll('%', '') ?? '') ?? 0;

    if (weather.contains('rain') || humidity > 85) {
      return "Today is not a good day to apply pesticides.";
    } else if (weather.contains('wind') && !weather.contains('light')) {
      return "Strong winds make it unsafe to apply pesticides today.";
    } else if (temperature > 30) {
      return "Temperature is too high for pesticide application.";
    } else if (weather.contains('cloud') && humidity >= 60 && humidity <= 85) {
      return "Today is a good day to apply pesticides.";
    } else if (weather.contains('clear') || weather.contains('sunny')) {
      if (temperature >= 15 && temperature <= 30 && humidity >= 40 && humidity <= 85) {
        return "Today is a good day to apply pesticides.";
      }
    }
    
    return "Weather conditions are not optimal for pesticide application.";
  }

  Future<Map<String, dynamic>?> getWeather(String city) async {
    print('🌤️ [WeatherService] Début de la requête météo pour la ville: $city');
    print('🔗 [WeatherService] URL de l\'API: $baseUrl?city=$city');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?city=$city'),
      );

      print('📡 [WeatherService] Statut de la réponse: ${response.statusCode}');
      print('📦 [WeatherService] Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          print('⚠️ [WeatherService] Corps de la réponse vide');
          return null;
        }
        
        try {
          final decodedData = json.decode(response.body);
          print('✅ [WeatherService] Données décodées avec succès: $decodedData');
          
          // Vérifier que les données nécessaires sont présentes
          if (decodedData['city'] == null || 
              decodedData['temperature'] == null || 
              decodedData['weather'] == null || 
              decodedData['humidity'] == null) {
            print('⚠️ [WeatherService] Données manquantes dans la réponse');
            throw Exception('Missing required weather data');
          }

          // Ajouter le conseil pour les pesticides
          decodedData['advice'] = _generatePesticideAdvice(decodedData);
          
          return decodedData;
        } catch (e) {
          print('❌ [WeatherService] Erreur de décodage JSON: $e');
          throw Exception('Invalid JSON response: ${response.body}');
        }
      } else if (response.statusCode == 500) {
        print('❌ [WeatherService] Erreur serveur 500');
        try {
          final errorBody = json.decode(response.body);
          throw Exception('Server error: ${errorBody['message'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Server error: ${response.body}');
        }
      } else {
        print('❌ [WeatherService] Erreur HTTP: ${response.statusCode}');
        try {
          final errorBody = json.decode(response.body);
          throw Exception('HTTP error ${response.statusCode}: ${errorBody['message'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('HTTP error ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ [WeatherService] Erreur lors de la récupération des données météo: $e');
      print('🔍 [WeatherService] Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getWeatherByCoordinates(double latitude, double longitude) async {
    print('🌤️ [WeatherApiService] Début de la récupération de la météo pour les coordonnées: $latitude, $longitude');
    
    // Déterminer la ville la plus proche en fonction des coordonnées
    String city = _getNearestCity(latitude, longitude);
    print('🌆 [WeatherApiService] Ville la plus proche: $city');
    
    return getWeather(city);
  }

  String _getNearestCity(double latitude, double longitude) {
    print('📍 [WeatherApiService] Recherche de la ville la plus proche pour les coordonnées: $latitude, $longitude');
    
    String nearestCity = 'Tunis'; // Ville par défaut
    double minDistance = double.infinity;
    
    // Calculer la distance à chaque ville et trouver la plus proche
    supportedCities.forEach((city, coordinates) {
      final cityLat = coordinates['lat']!;
      final cityLon = coordinates['lon']!;
      
      // Calculer la distance en utilisant la formule de Haversine
      final distance = _calculateDistance(latitude, longitude, cityLat, cityLon);
      
      print('📏 [WeatherApiService] Distance à $city: $distance km');
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    });
    
    print('✅ [WeatherApiService] Ville la plus proche trouvée: $nearestCity (${minDistance.toStringAsFixed(2)} km)');
    return nearestCity;
  }
  
  // Formule de Haversine pour calculer la distance entre deux points sur une sphère
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres
    
    // Convertir les degrés en radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    
    return distance;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
} 