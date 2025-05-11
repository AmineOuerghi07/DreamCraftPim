import 'package:pim_project/model/domain/land.dart';
import 'package:pim_project/model/domain/plant-with-quantity.dart';

class Region {
  final String id;
  final String name;
  final String? description;
  final Land land;
  final double surface;
  final List<String> sensors;
  final List<PlantWithQuantity> plants;
  final bool isConnected;

  Region({
    required this.id,
    required this.name,
    required this.land,
    required this.surface,  
    required this.description,
    List<String>? sensors,
    List<PlantWithQuantity>? plants,
    required this.isConnected,
  })  : sensors = sensors ?? [],
        plants = plants ?? [];

  factory Region.fromJson(Map<String, dynamic> json) {
     print("Raw Region JSON: $json");
    try {
      return Region(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        land: json['land'] is String
            ? Land(
                id: json['land'] as String,
                name: '',
                cordonate: '',
                forRent: false,
                surface: 0.0,
                image: '',
                regions: [],
                rentPrice: 0.0,
                userId: '',
              )
            : Land.fromJson(json['land'] as Map<String, dynamic>),
        surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
        sensors: (json['sensors'] as List<dynamic>?)
                ?.map((s) => s is String ? s : s['_id'].toString())
                .toList() ??
            [],
        plants: (json['plants'] as List<dynamic>?)
                ?.map((p) => PlantWithQuantity.fromJson(p is String ? {'plant': p} : p))
                .toList() ??
            [],
        isConnected: json['isConnected'] as bool? ?? false,
      );
    } catch (e, stack) {
      print('Error parsing Region: $e\n$stack');
      throw const FormatException('Invalid region data');
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'land': land.toJson(),
        'surface': surface,
        'sensors': sensors,
        'plants': plants.map((p) => p.toJson()).toList(),
        'isConnected': isConnected,
      };

  Region copyWith({
    String? id,
    String? name,
    String? description,
    Land? land,
    double? surface,
    List<String>? sensors,
    List<PlantWithQuantity>? plants,
    bool? isConnected,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      land: land ?? this.land,
      surface: surface ?? this.surface,
      sensors: sensors ?? this.sensors,
      plants: plants ?? this.plants,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}