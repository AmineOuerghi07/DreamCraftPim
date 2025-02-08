class Order {
  final String id;
  final DateTime date;       // Using DateTime for the date field.
  final String status;      // Order status (e.g., 'Pending', 'Shipped').
  final double price;       // Price of the order.
  final String name;        // Name of the customer or the person placing the order.
  final String phonenumber; // Customer's phone number.

  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.price,
    required this.name,
    required this.phonenumber,
  });
  }