class Plant {
  final String id;
  final String imageUrl;
  final String name;
  final String description;

  Plant({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
  });

  // Factory constructor to create a Plant object from JSON
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // Convert a Plant object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
    };
  }

  // Convert a Plant object to a Map (useful for saving to databases)
  Map<String, String> toMap() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
    };
  }

  // Create a copy of the current Plant object with modified fields
  Plant copyWith({
    String? id,
    String? imageUrl,
    String? name,
    String? description,
    int? quantity,
  }) {
    return Plant(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
