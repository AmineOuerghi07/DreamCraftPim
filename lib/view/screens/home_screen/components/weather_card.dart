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
    
    // Get screen size information
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.shortestSide >= 600;
    
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature and Weather Icon Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRTL) ...[
                  _buildWeatherIcon(condition, isTablet: isTablet),
                  const Spacer(),
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildWeatherIcon(condition, isTablet: isTablet),
                ],
              ],
            ),
            // Weather Condition Text
            Text(
              condition,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isTablet ? 28 : 20),
            
            // Weather Parameters
            LayoutBuilder(
              builder: (context, constraints) {
                // For very narrow screens, stack the parameters vertically
                if (constraints.maxWidth < 300) {
                  return Column(
                    children: displayParameters.entries.map((entry) {
                      final Widget paramWidget = entry.key == l10n.humidity
                          ? GestureDetector(
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
                              child: _buildWeatherParameter(
                                entry.key, 
                                entry.value, 
                                isTablet: isTablet,
                                isNarrow: true,
                              ),
                            )
                          : _buildWeatherParameter(
                              entry.key, 
                              entry.value, 
                              isTablet: isTablet,
                              isNarrow: true,
                            );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: paramWidget,
                      );
                    }).toList(),
                  );
                }
                
                // For wider screens, use row with spaceBetween
                return Row(
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
                        child: _buildWeatherParameter(
                          entry.key, 
                          entry.value, 
                          isTablet: isTablet
                        ),
                      );
                    }
                    return _buildWeatherParameter(
                      entry.key, 
                      entry.value, 
                      isTablet: isTablet
                    );
                  }).toList(),
                );
              },
            ),
            
            // Advice Section
            if (advice.isNotEmpty && advice != l10n.noAdviceAvailable)
              _buildWeatherAdvice(isTablet: isTablet),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherIcon(String condition, {bool isTablet = false}) {
    condition = condition.toLowerCase();
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 18;
    final double size = isTablet ? 70.0 : 50.0;
    
    if (condition.contains('01n') || (isNight && (condition.contains('clear') || condition.contains('sunny')))) {
      return MoonAnimation(size: size);
    } else if (condition.contains('01d') || (!isNight && (condition.contains('clear') || condition.contains('sunny')))) {
      return SunAnimation(size: size);
    } else if (condition.contains('cloud')) {
      return CloudAnimation(size: isTablet ? 80.0 : 60.0);
    } else if (condition.contains('rain')) {
      return RainDropsAnimation(isLarge: isTablet);
    } else if (condition.contains('snow')) {
      return SnowflakesAnimation(isLarge: isTablet);
    } else {
      return isNight ? MoonAnimation(size: size) : SunAnimation(size: size);
    }
  }

  Widget _buildWeatherParameter(
    String label, 
    String value, 
    {bool isTablet = false, bool isNarrow = false}
  ) {
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
    
    // For narrow screens, use a row layout instead of column
    if (isNarrow) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: getLabelColor(),
            ),
          ),
          const SizedBox(width: 8),
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
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: getValueTextColor(),
              ),
            ),
          ),
        ],
      );
    }

    // Normal column layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: getLabelColor(),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16, 
            vertical: isTablet ? 8 : 6
          ),
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
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: getValueTextColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAdvice({bool isTablet = false}) {
    return Container(
      margin: EdgeInsets.only(top: isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 136, 132, 132).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 184, 175, 175).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}