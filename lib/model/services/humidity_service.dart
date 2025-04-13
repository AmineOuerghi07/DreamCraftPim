import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:pim_project/constants/constants.dart';

class HumidityService {
  static const String baseUrl = 'http://127.0.0.1:3000/weather/humidity-details';
  
  // Liste des villes supportées avec leurs coordonnées
  static const Map<String, Map<String, double>> supportedCities = {
    'Tunis': {'lat': 36.8065, 'lon': 10.1815},
    'Sfax': {'lat': 34.7452, 'lon': 10.7613},
    'Sousse': {'lat': 35.8245, 'lon': 10.6346},
    'Bizerte': {'lat': 37.2744, 'lon': 9.8739},
    'Gabes': {'lat': 33.8881, 'lon': 10.0972}
  };
  
  Future<Map<String, dynamic>> getHumidityDetails(String city) async {
    print('💧 [HumidityService] Début de la requête d\'humidité pour la ville: $city');
    print('🔗 [HumidityService] URL de l\'API: $baseUrl?city=$city');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?city=$city'),
      );

      print('📡 [HumidityService] Statut de la réponse: ${response.statusCode}');
      print('📦 [HumidityService] Corps de la réponse: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          print('⚠️ [HumidityService] Corps de la réponse vide');
          return _getDefaultHumidityData();
        }
        
        try {
          final decodedData = json.decode(response.body) as Map<String, dynamic>;
          print('✅ [HumidityService] Données décodées avec succès: $decodedData');
          
          // Fusionner avec les données par défaut pour s'assurer que toutes les clés existent
          final defaultData = _getDefaultHumidityData();
          final Map<String, dynamic> mergedData = {
            'humidity': {
              ...defaultData['humidity'] as Map<String, dynamic>,
              ...(decodedData['humidity'] as Map<String, dynamic>? ?? {})
            },
            'dailySummary': {
              ...defaultData['dailySummary'] as Map<String, dynamic>,
              ...(decodedData['dailySummary'] as Map<String, dynamic>? ?? {})
            },
            'dailyComparison': {
              ...defaultData['dailyComparison'] as Map<String, dynamic>,
              ...(decodedData['dailyComparison'] as Map<String, dynamic>? ?? {})
            },
            'relativeHumidity': {
              ...defaultData['relativeHumidity'] as Map<String, dynamic>,
              ...(decodedData['relativeHumidity'] as Map<String, dynamic>? ?? {})
            }
          };
          
          return mergedData;
        } catch (e) {
          print('❌ [HumidityService] Erreur de décodage JSON: $e');
          return _getDefaultHumidityData();
        }
      } else {
        print('❌ [HumidityService] Erreur HTTP: ${response.statusCode}');
        return _getDefaultHumidityData();
      }
    } catch (e) {
      print('❌ [HumidityService] Erreur lors de la récupération des données d\'humidité: $e');
      print('🔍 [HumidityService] Stack trace: ${StackTrace.current}');
      return _getDefaultHumidityData();
    }
  }

  Map<String, dynamic> _getDefaultHumidityData() {
    return {
      'humidity': {
        'current': '0%',
        'dewPoint': '0°C',
        'hourlyReadings': [
          {'time': '6AM', 'value': '0%'},
          {'time': '12PM', 'value': '0%'},
          {'time': '6PM', 'value': '0%'},
          {'time': '12AM', 'value': '0%'}
        ],
        'chart': {
          'labels': ['6AM', '12PM', '6PM', '12AM'],
          'data': [0, 0, 0, 0],
          'scale': {
            'min': 0,
            'max': 100,
            'steps': [0, 20, 40, 60, 80, 100]
          }
        }
      },
      'dailySummary': {
        'averageHumidity': '0%',
        'dewPointRange': '0°C to 0°C',
        'description': 'No data available'
      },
      'dailyComparison': {
        'today': '0%',
        'yesterday': '0%',
        'difference': '0%',
        'trend': 'stable'
      },
      'relativeHumidity': {
        'definition': 'Relative humidity measures how much water vapor is in the air compared to the maximum possible at that temperature.',
        'currentImpact': 'No data available'
      }
    };
  }
  
  Future<Map<String, dynamic>> getHumidityByCoordinates(double latitude, double longitude) async {
    print('💧 [HumidityService] Début de la récupération de l\'humidité pour les coordonnées: $latitude, $longitude');
    
    String city = _getNearestCity(latitude, longitude);
    print('🌆 [HumidityService] Ville la plus proche: $city');
    
    return getHumidityDetails(city);
  }
  
  String _getNearestCity(double latitude, double longitude) {
    print('📍 [HumidityService] Recherche de la ville la plus proche pour les coordonnées: $latitude, $longitude');
    
    String nearestCity = 'Tunis'; // Ville par défaut
    double minDistance = double.infinity;
    
    supportedCities.forEach((city, coordinates) {
      final cityLat = coordinates['lat']!;
      final cityLon = coordinates['lon']!;
      
      final distance = _calculateDistance(latitude, longitude, cityLat, cityLon);
      
      print('📏 [HumidityService] Distance à $city: $distance km');
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    });
    
    print('✅ [HumidityService] Ville la plus proche trouvée: $nearestCity (${minDistance.toStringAsFixed(2)} km)');
    return nearestCity;
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;
    
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