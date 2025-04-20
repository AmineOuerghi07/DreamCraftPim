import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/view_model/humidity_view_model.dart';
import 'package:fl_chart/fl_chart.dart';

class HumidityScreen extends StatelessWidget {
  final String city;
  final String humidity;
  
  const HumidityScreen({
    Key? key, 
    required this.city,
    required this.humidity,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HumidityViewModel()..fetchHumidityData(city),
      child: _HumidityScreenContent(city: city, humidity: humidity),
    );
  }
}

class _HumidityScreenContent extends StatelessWidget {
  final String city;
  final String humidity;
  
  const _HumidityScreenContent({
    Key? key, 
    required this.city,
    required this.humidity,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Humidité - $city',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<HumidityViewModel>(
        builder: (context, viewModel, child) {
          print('🔄 Mise à jour de l\'interface avec le ViewModel');
          print('⏳ État de chargement: ${viewModel.isLoading}');
          print('❌ Erreur: ${viewModel.error}');
          print('📊 Données: ${viewModel.humidityData != null ? "Présentes" : "Absentes"}');
          
          if (viewModel.humidityData != null) {
            print('📦 Données d\'humidité: ${viewModel.humidityData}');
          }

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF29B6F6)),
              ),
            );
          }
          
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchHumidityData(city),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          
          final humidityData = viewModel.humidityData;
          if (humidityData == null) {
            return const Center(
              child: Text('Aucune donnée disponible'),
            );
          }
          
         return SingleChildScrollView(
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildCombinedHumidityBox(humidityData),
            ),
            const SizedBox(width: 16),
            /*
            Expanded(
              flex: 3,
              child: _buildCombinedHumidityBox(humidityData),
            ),
            */
          ],
        ),
      ),
      _buildHumidityGraph(humidityData),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
        ),
      ),
      _buildRelativeHumidity(humidityData),
    ],
  ),
);
        },
      ),
    );
  }
  ///integrer les deux box 
Widget _buildCombinedHumidityBox(Map<String, dynamic> data) {
  final humidity = data['humidity']?['current'] ?? '0%';
  final dewPoint = data['humidity']?['dewPoint'] ?? 'N/A';

  final dailySummary = data['dailySummary'] as Map<String, dynamic>?; 
  final averageHumidity = dailySummary?['averageHumidity'] ?? 'N/A'; 
  final dewPointRange = dailySummary?['dewPointRange'] ?? 'N/A';

  return Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Less padding
 width: 260, // Narrower width
  height: 280, // Smaller height to match card style
      decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.water_drop,
          color: Colors.white,
          size: 28, // Increased icon size for more visual balance
        ),
        Center(
          child: Column(
            children: [
              Text(
                humidity,
                style: const TextStyle(
                  fontSize: 32, // Increased font size for visibility
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Humidité actuelle',
                style: TextStyle(
                  fontSize: 16, // Adjusted text size for a better fit
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // More space between sections
        _buildHumidityInfoRow(Icons.thermostat, 'Point de rosée', dewPoint),
        const Divider(height: 32, color: Colors.white30),
        const Text(
          'Détails journaliers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _buildHumidityInfoRow(Icons.water_drop, 'Humidité moyenne', averageHumidity),
        const SizedBox(height: 8),
        _buildHumidityInfoRow(Icons.thermostat_auto, 'Plage point de rosée', dewPointRange),
      ],
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

  /*
  Widget _buildCurrentHumidity(Map<String, dynamic> data) {
    final humidity = data['humidity']?['current'] ?? '0%';
    final dewPoint = data['humidity']?['dewPoint'] ?? 'N/A';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.water_drop,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            humidity,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Humidité actuelle',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.thermostat,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Point de rosée: $dewPoint',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildHumidityDetails(Map<String, dynamic> data) {
    final dailySummary = data['dailySummary'] as Map<String, dynamic>?;
    final averageHumidity = dailySummary?['averageHumidity'] ?? 'N/A';
    final dewPointRange = dailySummary?['dewPointRange'] ?? 'N/A';
    
    return Container(
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
          const Text(
            'Détails',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.water_drop,
            label: 'Humidité moyenne',
            value: averageHumidity,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.thermostat,
            label: 'Plage point de rosée',
            value: dewPointRange,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0288D1)),
        const SizedBox(width: 8),
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
    );
  }
  */
  Widget _buildHumidityGraph(Map<String, dynamic> data) {
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
          const Text(
            'Évolution de l\'humidité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
           // height: 300,
            width: double.infinity,
            child: CustomPaint(
              size: const Size(double.infinity, 300),
              painter: HumidityChartPainter(
                labels: labels,
                data: values,
                minValue: scale?['min'] ?? 0,
                maxValue: scale?['max'] ?? 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailySummary(Map<String, dynamic> data) {
    final dailySummary = data['dailySummary'];
    String description = 'Aucun résumé disponible';
    
    if (dailySummary is Map<String, dynamic>) {
      description = dailySummary['description'] ?? 'Aucun résumé disponible';
    } else if (dailySummary is String) {
      description = dailySummary;
    }
    
    return Container(
       width: 160, 
    height: 160, 
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
          const Text(
            'Résumé quotidien',
            style: TextStyle(
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
          ),
        ],
      ),
    );
  }

  Widget _buildDailyComparison(Map<String, dynamic> data) {
    final comparison = data['dailyComparison'] as Map<String, dynamic>?;
    if (comparison == null) return const SizedBox.shrink();
    
    return Container(
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
          const Text(
            'Comparaison journalière',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const SizedBox(height: 12),
          _buildComparisonRow('Aujourd\'hui', comparison['today'] ?? 'N/A'),
          _buildComparisonRow('Hier', comparison['yesterday'] ?? 'N/A'),
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
        children: [
          const Text(
            'Humidité relative',
            style: TextStyle(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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