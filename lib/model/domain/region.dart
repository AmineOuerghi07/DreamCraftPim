
class Region {
  final String id;
  final String name;
  final String land; 
  final double surface; // Correct type to double
  final List<String> sensors; 
  final List<String> plants; 

  Region({
    required this.id,
    required this.name,
    required this.land,
    required this.surface, // Ensure surface is required in the constructor
    List<String>? sensors, 
    List<String>? plants, 
  })  : sensors = sensors ?? [],
        plants = plants ?? [];

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'] as String,
      name: json['name'] as String,
      land: json['land'] is String ? json['land'] : json['land']['_id'],
      surface: (json['surface'] as num?)?.toDouble() ?? 0.0, // Ensure surface is parsed as double
      sensors: (json['sensors'] as List<dynamic>?)
              ?.map((s) => s is String ? s : s['_id'].toString())
              .toList() ?? [],
      plants: (json['plants'] as List<dynamic>?)
              ?.map((p) => p is String ? p : p['_id'].toString())
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'land': land,
        'surface': surface, // Add surface in the toJson method
        'sensors': sensors,
        'plants': plants,
      };

  Region copyWith({
    String? id,
    String? name,
    String? land,
    double? surface, // Correct type to double
    List<String>? sensors,
    List<String>? plants,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      land: land ?? this.land,
      surface: surface ?? this.surface, // Handle surface in copyWith
      sensors: sensors ?? this.sensors,
      plants: plants ?? this.plants,
    );
  }
}
