class Plant {
  final String id;
  final String imageUrl;
  final String name;
  final String description;
  final int quantity;

  Plant({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.quantity,
  });

  // Factory constructor to create a Plant object from JSON
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert a Plant object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }

  // Convert a Plant object to a Map (useful for saving to databases)
  Map<String, String> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
      'quantity': quantity.toString(),
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
      quantity: quantity ?? this.quantity,
    );
  }
}
