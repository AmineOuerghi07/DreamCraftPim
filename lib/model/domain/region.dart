import 'package:pim_project/model/domain/land.dart';

class Region {
  final String id;
  final String name;
  final Land land; // Changed to Land object
  final double surface;
  final List<String> sensors;
  final List<String> plants;

  Region({
    required this.id,
    required this.name,
    required this.land,
    required this.surface,
    List<String>? sensors,
    List<String>? plants,
  })  : sensors = sensors ?? [],
        plants = plants ?? [];

  factory Region.fromJson(Map<String, dynamic> json) {
    try {
      return Region(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        land: json['land'] is String
            ? Land(
                id: json['land'] as String,
                name: '', // Default values if only ID is provided
                cordonate: '',
                forRent: false,
                surface: 0.0,
                image: '',
                regions: [],
              )
            : Land.fromJson(json['land'] as Map<String, dynamic>),
        surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
        sensors: (json['sensors'] as List<dynamic>?)
                ?.map((s) => s is String ? s : s['_id'].toString())
                .toList() ??
            [],
        plants: (json['plants'] as List<dynamic>?)
                ?.map((p) => p is String ? p : p['_id'].toString())
                .toList() ??
            [],
      );
    } catch (e, stack) {
      print('Error parsing Region: $e\n$stack');
      throw const FormatException('Invalid region data');
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'land': land.toJson(), // Assuming Land has a toJson method
        'surface': surface,
        'sensors': sensors,
        'plants': plants,
      };

  Region copyWith({
    String? id,
    String? name,
    Land? land, // Updated to Land type
    double? surface,
    List<String>? sensors,
    List<String>? plants,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      land: land ?? this.land,
      surface: surface ?? this.surface,
      sensors: sensors ?? this.sensors,
      plants: plants ?? this.plants,
    );
  }
}