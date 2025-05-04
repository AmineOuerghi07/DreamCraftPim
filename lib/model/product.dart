class Product {
  final String id;
  final String name;
  final String? description; // Nullable
  final String? category; // Nullable
  final double price;
  final int stockQuantity;
  final String image;
  int? quantity;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.price,
    required this.stockQuantity,
    this.quantity,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? 'Unknown', // Fallback if _id is missing
      name: json['name'] ?? 'No Name', // Fallback if name is missing
      description: json['description'] ?? '', // Default to empty string if missing
      category: json['category'] ?? '', // Default to empty string if missing
      price: json['price']?.toDouble() ?? 0.0, // Ensure price is a double or 0.0
      stockQuantity: json['stockQuantity'] ?? 0, // Fallback to 0 if stockQuantity is missing
      quantity: json['quantity'] ?? 0, // Fallback to 0 if quantity is missing
      image: json['image'] ?? '', // Default to empty string if missing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'quantity': quantity ?? 0, // Default to 0 if null
      'image': image,
    };
  }
}
