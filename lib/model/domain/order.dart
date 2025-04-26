class OrderItem {
  final String productId;
  final int quantity;
  

  OrderItem({
    required this.productId,
    required this.quantity,
   
  });

  // Factory to create OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
     
    );
  }

  // Convert OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
     
    };
  }
}

class Order {
  final String customerId;
  final String orderStatus;
  final double totalAmount;
  final List<OrderItem>? orderItems; 
  final DateTime createdAt;

  Order({
    required this.customerId,
    required this.orderStatus,
    required this.totalAmount,
    this.orderItems, 
    required this.createdAt,
  });

  // Factory constructor to create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: json['customerId'] ?? 'Unknown', // Fallback if customerId is missing
      orderStatus: json['orderStatus'] ?? 'Pending', // Fallback if status is missing
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0, // Ensure double or 0.0
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null, // Parse orderItems if present
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()), // Parse createdAt or use current time
    );
  }

  // Method to convert Order to JSON (matches CreateOrderDto)
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'orderStatus': orderStatus,
      'totalAmount': totalAmount,
      'orderItems': orderItems?.map((item) => item.toJson()).toList() ?? [],
      'createdAt': createdAt.toIso8601String(),
    };
  }
}