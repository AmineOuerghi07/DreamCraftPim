class Region {
  final String id;
  final String name;
  final double surface;

  Region({
    required this.id,
    required this.name,
    required this.surface,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'],
      name: json['name'],
      surface: json['surface'].toDouble(),
    );
  }
}