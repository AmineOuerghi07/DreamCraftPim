import 'package:pim_project/model/domain/region.dart';

class Land {
  final String id;
  final String name;
  final String cordonate;
  final bool forRent;
  final double surface;
  final String image;
  final List<Region> regions;
  

  Land({
    required this.id,
    required this.name,
    required this.cordonate,
    required this.forRent,
    required this.surface,
    required this.image,
    required this.regions,
  });

factory Land.fromJson(Map<String, dynamic> json) {
  try {
    return Land(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      cordonate: json['cordonate'] ?? '',
      forRent: json['forRent'] ?? false,
      surface: (json['surface'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      regions: (json['regions'] as List<dynamic>? ?? [])
          .map((r) => Region.fromJson(r))
          .toList(),
    );
  } catch (e, stack) {
    print('Error parsing Land: $e\n$stack');
    throw FormatException('Invalid land data');
  }
}
 Map<String, String> toMap() {
    return {
      'name': name,
      'cordonate': cordonate,
      'surface': surface.toString(),
      'forRent': forRent.toString(),
      'user': "67ba2be5c1e090ed269faa5a"
    };
  }

  Land copyWith({
    String? id,
    String? name,
    String? cordonate,
    bool? forRent,
    double? surface,
    String? image,
    List<Region>? regions,
  }) {
    return Land(
      id: id ?? this.id,
      name: name ?? this.name,
      cordonate: cordonate ?? this.cordonate,
      forRent: forRent ?? this.forRent,
      surface: surface ?? this.surface,
      image: image ?? this.image,
      regions: regions ?? this.regions,
    );
  }
}