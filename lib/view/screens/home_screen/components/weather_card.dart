import 'package:flutter/material.dart';
import 'package:pim_project/view/screens/home_screen/components/components_animations.dart';
import 'package:pim_project/view/screens/humidity_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Color _getPrimaryColor(String condition, String temperature) {
  // Extract numeric temperature value
  double temp = double.tryParse(temperature.replaceAll('°C', '').trim()) ?? 18;
  
  if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
    if (temp > 30) {
      return Color(0xFFF9A825); // Hot sunny - deeper orange/yellow
    } else if (temp > 20) {
      return Color(0xFFFFD54F); // Warm sunny - bright yellow
    } else {
      return Color(0xFFFFE082); // Cool sunny - light yellow
    }
  } else if (condition.toLowerCase().contains('cloud')) {
    if (temp < 16) {
      return Color(0xFF90A4AE); // Cool cloudy - bluish gray
    } else {
      return Color(0xFFBDBDBD); // Warm cloudy - light gray
    }
  } else if (condition.toLowerCase().contains('rain')) {
    return Color(0xFF64B5F6); // Rain - blue
  } else if (condition.toLowerCase().contains('snow')) {
    return Color(0xFFB3E5FC); // Snow - pale sky blue
   } else {
    // Default
    return Color(0xFFFECC71);
  }
}

Color _getSecondaryColor(String condition, String temperature) {
  // Extract numeric temperature value
  double temp = double.tryParse(temperature.replaceAll('°C', '').trim()) ?? 18;
  
  if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
    if (temp > 30) {
      return Color(0xFFFBC02D); // Hot sunny - golden
    } else if (temp > 20) {
      return Color(0xFFFFE0B2); // Warm sunny - light orange
    } else {
      return Color(0xFFFFF9C4); // Cool sunny - very light yellow
    }
  } else if (condition.toLowerCase().contains('cloud')) {
    if (temp < 16) {
      return Color(0xFFCFD8DC); // Cool cloudy - very light bluish gray
    } else {
      return Color(0xFFE0E0E0); // Warm cloudy - lighter gray
    }
  } else if (condition.toLowerCase().contains('rain')) {
    return Color(0xFFBBDEFB); // Rain - lighter blue
  } else if (condition.toLowerCase().contains('snow')) {
    return Color(0xFFE1F5FE); // Snow - very light ice blue
  } else {
    // Default
    return Color(0xFFFFE1A9);
  }
}

class WeatherCard extends StatelessWidget {
  final String temperature;
  final String condition;
  final String humidity;
  final String advice;
  final String precipitation;
  final String soilCondition;
  final Map<String, String> parameters;
  final String city;
  final double latitude;
  final double longitude;

  const WeatherCard({
    Key? key,
    this.temperature = '18°C',
    required this.condition, 
    this.humidity = 'N/A',
    this.advice = 'Aucun conseil disponible',
    this.precipitation = '0%',
    this.soilCondition = 'N/A',
    this.parameters = const {},
    required this.city,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final Color primaryColor = _getPrimaryColor(condition, temperature);
    final Color secondaryColor = _getSecondaryColor(condition, temperature);
    
    // Créer les paramètres à partir des valeurs individuelles
    final Map<String, String> displayParameters = {
      l10n.humidity: humidity,
      l10n.precipitation: precipitation,
      l10n.soilCondition: soilCondition,
    };
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isRTL ? Alignment.centerRight : Alignment.centerLeft,
          end: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
          ],
          stops: const [0.0, 0.6],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRTL) ...[
                  _buildWeatherIcon(condition),
                  const Spacer(),
                  Text(
                    temperature,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    temperature,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildWeatherIcon(condition),
                ],
              ],
            ),
            Text(
              condition,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: displayParameters.entries.map((entry) {
                if (entry.key == l10n.humidity) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HumidityScreen(
                            latitude: latitude,
                            longitude: longitude,
                            humidity: humidity,
                          ),
                        ),
                      );
                    },
                    child: _buildWeatherParameter(entry.key, entry.value),
                  );
                }
                return _buildWeatherParameter(entry.key, entry.value);
              }).toList(),
            ),
            if (advice.isNotEmpty && advice != l10n.noAdviceAvailable)
              _buildWeatherAdvice(),
          ],
        ),
      ),
    );
  }
   Widget _buildWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;
    
    if (condition.contains('01n') || (isNight && (condition.contains('clear') || condition.contains('sunny')))) {
      return const MoonAnimation(size: 50);
    } else if (condition.contains('01d') || (!isNight && (condition.contains('clear') || condition.contains('sunny')))) {
      return const SunAnimation(size: 50);
    } else if (condition.contains('cloud')) {
      return const CloudAnimation(size: 60);
    } else if (condition.contains('rain')) {
      return const RainDropsAnimation();
    } else if (condition.contains('snow')) {
      return const SnowflakesAnimation();
    } else {
      return isNight ? const MoonAnimation(size: 50) : const SunAnimation(size: 50);
    }
  }

 Widget _buildWeatherParameter(String label, String value) {
  // Determine text color based on current weather condition
  Color getLabelColor() {
    if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
      return Colors.brown[700]!; // Darker brown for sunny backgrounds
    } else if (condition.toLowerCase().contains('cloud')) {
      return Colors.teal[700]!; // Darker teal for cloudy backgrounds
    } else if (condition.toLowerCase().contains('rain')) {
      return Colors.indigo[300]!; // Light indigo for rainy backgrounds
    } else if (condition.toLowerCase().contains('snow')) {
      return Colors.blueGrey[700]!; // Dark blue-grey for snowy backgrounds
    } else {
      return Colors.teal[200]!; // Original fallback color
    }
  }

  // Get the appropriate background color for the value container
  Color getValueBgColor() {
    // Subtle background color that complements the main background
    if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
      return Colors.white.withOpacity(0.9); // Slightly transparent white
    } else if (condition.toLowerCase().contains('rain') || condition.toLowerCase().contains('snow')) {
      return Colors.white.withOpacity(0.85); // More transparent white
    } else {
      return Colors.white; // Fully opaque white for other conditions
    }
  }

  // Text color for the value
  Color getValueTextColor() {
    if (condition.toLowerCase().contains('sunny') || condition.toLowerCase().contains('clear')) {
      return Colors.orange[800]!; // Orange for sunny
    } else if (condition.toLowerCase().contains('cloud')) {
      return Colors.blueGrey[700]!; // Blue-grey for cloudy
    } else if (condition.toLowerCase().contains('rain')) {
      return Colors.blue[700]!; // Blue for rainy
    } else if (condition.toLowerCase().contains('snow')) {
      return Colors.indigo[800]!; // Indigo for snowy
    } else {
      return Colors.black87; // Default dark text
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: getLabelColor(),
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: getValueBgColor(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: getValueTextColor(),
          ),
        ),
      ),
    ],
  );
}

Widget _buildWeatherParameters(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildParameterItem(
        context,
        Icons.water_drop,
        'Humidité',
        '$humidity%',
        onTap: () {
          print('🟢 Clic sur l\'humidité détecté');
          print('📊 Valeur de l\'humidité: $humidity');
          print('🌆 Ville actuelle: $city');
          
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HumidityScreen(
                  latitude: latitude,
                  longitude: longitude,
                  humidity: humidity,
                ),
              ),
            );
            print('✅ Navigation vers HumidityScreen réussie');
          } catch (e) {
            print('❌ Erreur lors de la navigation: $e');
          }
        },
      ),
      _buildParameterItem(
        context,
        Icons.water,
        'Précipitations',
        '$precipitation mm',
        onTap: null,
      ),
      _buildParameterItem(
        context,
        Icons.terrain,
        'Soil',
        soilCondition,
        onTap: null,
      ),
    ],
  );
}

Widget _buildParameterItem(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Icon(icon, color: _getPrimaryColor(condition, temperature), size: 24),
        Text(
          label,
          style: TextStyle(
            color: _getSecondaryColor(condition, temperature),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: _getSecondaryColor(condition, temperature),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildWeatherAdvice() {
  return Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 136, 132, 132).withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color.fromARGB(255, 184, 175, 175).withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.lightbulb_outline,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            advice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
}



