class Region {
  final String id;
  final String name;
  final String land; 
  final List<String> sensors; 
  final List<String> plants; 

  Region({
    required this.id,
    required this.name,
    required this.land,
    List<String>? sensors, 
    List<String>? plants, 
  })  : sensors = sensors ?? [],
        plants = plants ?? [];

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'] as String,
      name: json['name'] as String,
      land: json['land'] is String ? json['land'] : json['land']['_id'],
      sensors: (json['sensors'] as List<dynamic>?)
              ?.map((s) => s is String ? s : s['_id'].toString())
              .toList() ??
          [],
      plants: (json['plants'] as List<dynamic>?)
              ?.map((p) => p is String ? p : p['_id'].toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'land': land,
        'sensors': sensors,
        'plants': plants,
      };

  Region copyWith({
    String? id,
    String? name,
    String? land,
    List<String>? sensors,
    List<String>? plants,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      land: land ?? this.land,
      sensors: sensors ?? this.sensors,
      plants: plants ?? this.plants,
    );
  }
}
