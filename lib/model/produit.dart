class Produit {
  final String id;    // Unique identifier for the product
  final String name;  // Name of the product
  final double price; // Price of the product
  final int qte;      // Quantity of the product

  Produit({
    required this.id,
    required this.name,
    required this.price,
    required this.qte,
  });
}