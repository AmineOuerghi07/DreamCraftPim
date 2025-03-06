import 'package:pim_project/model/domain/land.dart';

class Region {
  final String id;
  final String name;
  final double surface;
  final Land land;   // You can use double for surface area (e.g., in square meters).

  Region({
    required this.id,
    required this.name,
    required this.surface,
    required this.land,
  });



  
  // Factory method to create a Region object from JSON data.
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['_id'],
      name: json['name'],
      surface: json['surface']?.toDouble() ?? 0.0, // Convert to double or default to 0.0.
      land: Land.fromJson(json['land']), // Parse the associated land.
    );
  }
  }