// view/screens/humidity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/humidity_view_model.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HumidityScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String humidity;
  final Color? backgroundColor;
  final Color? secondaryColor;
  
  const HumidityScreen({
    Key? key, 
    required this.latitude,
    required this.longitude,
    required this.humidity,
    this.backgroundColor,
    this.secondaryColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HumidityViewModel()..fetchHumidityDataByCoordinates(latitude, longitude),
      child: _HumidityScreenContent(
        latitude: latitude, 
        longitude: longitude, 
        humidity: humidity,
        backgroundColor: backgroundColor,
        secondaryColor: secondaryColor,
      ),
    );
  }
}

class _HumidityScreenContent extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String humidity;
  final Color? backgroundColor;
  final Color? secondaryColor;
  
  const _HumidityScreenContent({
    Key? key, 
    required this.latitude,
    required this.longitude,
    required this.humidity,
    this.backgroundColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<_HumidityScreenContent> createState() => _HumidityScreenContentState();
}

class _HumidityScreenContentState extends State<_HumidityScreenContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final List<Star> _stars = [];
  bool _isNight = false;
  bool _starsInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Vérifier l'heure pour déterminer si c'est la nuit
    final hour = DateTime.now().hour;
    _isNight = hour < 6 || hour > 18;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_starsInitialized) {
      _initializeStars();
      _starsInitialized = true;
    }
  }

  void _initializeStars() {
    if (!mounted) return;
    
    _stars.clear();
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: Random().nextDouble() * MediaQuery.of(context).size.width,
        y: Random().nextDouble() * MediaQuery.of(context).size.height * 0.5,
        size: Random().nextDouble() * 2 + 1,
        twinkle: Random().nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(String condition) {
    if (_isNight) {
      return const Color(0xFF1A237E);
    }
    
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'cloudy':
        return const Color(0xFF78909C);
      case 'sunny':
      case 'clear':
        return const Color(0xFFFFB300);
      case 'rainy':
      case 'rain':
        return const Color(0xFF42A5F5);
      case 'snow':
      case 'snowy':
        return const Color(0xFF90CAF9);
      case 'storm':
      case 'thunderstorm':
        return const Color(0xFF37474F);
      case 'fog':
      case 'mist':
        return const Color(0xFF9E9E9E);
      case 'windy':
      case 'breezy':
        return const Color(0xFF80DEEA);
      case 'hazy':
      case 'smoky':
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFF2196F3);
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.humidityTitle),
        backgroundColor: widget.backgroundColor ?? Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<HumidityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: Text(l10n.humidityLoading));
          }

          if (viewModel.error != null) {
            return Center(child: Text(l10n.humidityError));
          }

          final humidityData = viewModel.humidityData;
          if (humidityData == null) {
            return Center(child: Text(l10n.humidityNoData));
          }

          final condition = humidityData['weather']?['condition']?.toLowerCase() ?? '';
          
          // Use passed colors from weather card if available, otherwise calculate based on condition
          final primaryColor = widget.backgroundColor ?? _getBackgroundColor(condition);
          final secondaryColor = widget.secondaryColor ?? primaryColor.withOpacity(0.6);

          return Stack(
            children: [
              // Fond animé
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      secondaryColor,
                      primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // Étoiles pour la nuit
              if (_isNight)
                ..._stars.map((star) => AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      left: star.x,
                      top: star.y + (star.twinkle ? _animation.value * 5 : 0),
                      child: Opacity(
                        opacity: star.twinkle ? 0.3 + (_animation.value * 0.7) : 0.7,
                        child: Container(
                          width: star.size,
                          height: star.size,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                )),

              // Contenu principal
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildAnimatedHumidityBox(humidityData),
                          ),
                        ],
                      ),
                    ),
                    _buildAnimatedHumidityGraph(humidityData),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // For narrow screens, stack summary widgets vertically
                          if (constraints.maxWidth < 600) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDailySummary(humidityData),
                                const SizedBox(height: 16),
                                _buildDailyComparison(humidityData),
                              ],
                            );
                          } 
                          // For wider screens, place them side by side
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildDailySummary(humidityData),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDailyComparison(humidityData),
                              ),
                            ],
                          );
                        }
                      ),
                    ),
                    _buildRelativeHumidity(humidityData),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHumidityBox(Map<String, dynamic> data) {
  //  final l10n = AppLocalizations.of(context)!;
    final condition = data['weather']?['condition']?.toLowerCase() ?? '';
    
    // Use passed colors if available, otherwise calculate based on condition
    final startColor = widget.backgroundColor ?? const Color(0xFF29B6F6);
    final endColor = widget.secondaryColor ?? _getBackgroundColor(condition);
    
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: ColorTween(
        begin: startColor,
        end: endColor,
      ),
      builder: (context, Color? color, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color ?? startColor,
                color?.withOpacity(0.7) ?? endColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (color ?? startColor).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: constraints.maxWidth < 300 
                    ? CrossAxisAlignment.center 
                    : CrossAxisAlignment.start,
                children: [
                  _buildWeatherIcon(condition),
                  const SizedBox(height: 12),
                  _buildCombinedHumidityBox(data),
                ],
              );
            }
          ),
        );
      },
    );
  }

  Widget _buildWeatherIcon(String condition) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Icon(
        _getWeatherIcon(condition),
        key: ValueKey<String>(condition),
        color: Colors.white,
        size: 48,
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    if (_isNight) {
      return Icons.nightlight_round;
    }
    
    switch (condition.toLowerCase()) {
      case 'cloudy':
        return Icons.cloud;
      case 'sunny':
        return Icons.wb_sunny;
      case 'rainy':
        return Icons.grain;
      default:
        return Icons.water_drop;
    }
  }

  Widget _buildCombinedHumidityBox(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final humidity = data['humidity']?['current'] ?? '0%';
    final dewPoint = data['humidity']?['dewPoint'] ?? 'N/A';

    final dailySummary = data['dailySummary'] as Map<String, dynamic>?; 
    final averageHumidity = dailySummary?['averageHumidity'] ?? 'N/A'; 
    final dewPointRange = dailySummary?['dewPointRange'] ?? 'N/A';

    // Use passed colors if available, otherwise use default blue gradient
    final startColor = widget.backgroundColor ?? const Color(0xFF29B6F6);
    final endColor = widget.secondaryColor ?? const Color(0xFF0288D1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;
          
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                if (!isNarrow)
                  const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 28,
                  ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        humidity,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.humidityCurrent,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildHumidityInfoRow(Icons.thermostat, l10n.humidityDewPoint, dewPoint),
                const Divider(height: 32, color: Colors.white30),
                Text(
                  l10n.humidityDailyDetails,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHumidityInfoRow(Icons.water_drop, l10n.humidityAverage, averageHumidity),
                const SizedBox(height: 8),
                _buildHumidityInfoRow(Icons.thermostat_auto, l10n.humidityDewPointRange, dewPointRange),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildHumidityInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildHumidityGraph(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final humidity = data['humidity'] as Map<String, dynamic>?;
    if (humidity == null) return const SizedBox.shrink();
    
    final chart = humidity['chart'] as Map<String, dynamic>?;
    if (chart == null) return const SizedBox.shrink();
    
    final labels = (chart['labels'] as List<dynamic>?)?.cast<String>() ?? [];
    final values = (chart['data'] as List<dynamic>?)?.cast<int>() ?? [];
    final scale = chart['scale'] as Map<String, dynamic>?;
    
    if (labels.isEmpty || values.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.humidityEvolution,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Adjust chart height based on available width
              final chartHeight = constraints.maxWidth < 400 ? 200.0 : 300.0;
              
              return SizedBox(
                height: chartHeight,
                width: double.infinity,
                child: CustomPaint(
                  size: Size(double.infinity, chartHeight),
                  painter: HumidityChartPainter(
                    labels: labels,
                    data: values,
                    minValue: scale?['min'] ?? 0,
                    maxValue: scale?['max'] ?? 100,
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailySummary(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final dailySummary = data['dailySummary'];
    String description = l10n.humidityNoData;
    
    if (dailySummary is Map<String, dynamic>) {
      description = dailySummary['description'] ?? l10n.humidityNoData;
    } else if (dailySummary is String) {
      description = dailySummary;
    }
    
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.humidityDailySummary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyComparison(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final comparison = data['dailyComparison'] as Map<String, dynamic>?;
    if (comparison == null) return const SizedBox.shrink();
    
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.humidityDailyComparison,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(l10n.humidityToday, comparison['today'] ?? l10n.humidityNoData),
          _buildComparisonRow(l10n.humidityYesterday, comparison['yesterday'] ?? l10n.humidityNoData),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  comparison['trend'] == 'increasing' 
                      ? Icons.trending_up 
                      : Icons.trending_down,
                  size: 16,
                  color: const Color(0xFF0288D1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comparison['difference'] ?? 'Pas de changement',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelativeHumidity(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final relativeHumidity = data['relativeHumidity'] as Map<String, dynamic>?;
    if (relativeHumidity == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),    
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.humidityRelative,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 12),
            
          Text(
            relativeHumidity['definition'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    relativeHumidity['currentImpact'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHumidityGraph(Map<String, dynamic> data) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: _buildHumidityGraph(data),
          ),
        );
      },
    );
  }
}

class HumidityChartPainter extends CustomPainter {
  final List<String> labels;
  final List<int> data;
  final int minValue;
  final int maxValue;

  HumidityChartPainter({
    required this.labels,
    required this.data,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0288D1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0288D1).withOpacity(0.3),
          const Color(0xFF0288D1).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final path = Path();
    final width = size.width;
    final height = size.height;
    final padding = 50.0;
    final graphWidth = width - (padding * 2);
    final graphHeight = height - (padding * 2);

    // Dessiner les lignes de grille horizontales
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    final steps = 5;
    for (var i = 0; i <= steps; i++) {
      final y = padding + (graphHeight * i / steps);
      canvas.drawLine(
        Offset(padding, y),
        Offset(width - padding, y),
        gridPaint,
      );
      
      // Ajouter les valeurs sur l'axe Y
      final value = ((maxValue - minValue) * (steps - i) / steps + minValue).round();
      textPainter.text = TextSpan(
        text: '$value%',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Dessiner la ligne du graphique
    for (var i = 0; i < data.length; i++) {
      final x = padding + (graphWidth * i / (data.length - 1));
      final y = height - padding - (graphHeight * (data[i] - minValue) / (maxValue - minValue));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Dessiner la zone remplie
    final fillPath = Path.from(path);
    fillPath.lineTo(width - padding, height - padding);
    fillPath.lineTo(padding, height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Dessiner les points sur la ligne
    final pointPaint = Paint()
      ..color = const Color(0xFF0288D1)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      final x = padding + (graphWidth * i / (data.length - 1));
      final y = height - padding - (graphHeight * (data[i] - minValue) / (maxValue - minValue));
      
      // Point extérieur
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      
      // Point intérieur blanc
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = Colors.white,
      );
    }

    // Dessiner les labels de l'axe X
    for (var i = 0; i < labels.length; i++) {
      final x = padding + (graphWidth * i / (labels.length - 1));
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, height - padding + 12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Star {
  final double x;
  final double y;
  final double size;
  final bool twinkle;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkle,
  });
} 