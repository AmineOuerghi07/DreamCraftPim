import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/order.dart';
import 'package:pim_project/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FactureProvider extends ChangeNotifier {
  bool editMode = false;
  int? selectedRowIndex;
  List<Map<String, dynamic>> _products = [];
  List<Order> _orders = [];
  bool _isFetching = false;

  List<Map<String, dynamic>> get products => _products;
  List<Order> get orders => _orders;

  void toggleEditMode() {
    editMode = !editMode;
    selectedRowIndex = null;
    notifyListeners();
  }

  void closeEditMode() {
    editMode = false;
    notifyListeners();
  }

  void selectRow(int index) {
    selectedRowIndex = index;
    notifyListeners();
  }

  void deleteElement(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  void setProducts(List<Map<String, dynamic>> products) {
    _products = products;
    notifyListeners();
  }


  Future<Product> fetchProductById(String productId) async {
    final response = await http.get(Uri.parse('http://localhost:3000/product/$productId'));

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product details');
    }
  }


  Future<void> createOrder(BuildContext context, double totalAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> cartQte = prefs.getStringList('cartQte') ?? [];
    var customerId = MyApp.userId;
    String baseUrl = 'http://localhost:3000/order';

    // Build orderItems using OrderItem class
    List<OrderItem> orderItems = [];
    for (int i = 0; i < cart.length; i++) {
      String productId = cart[i];
      int quantity = int.tryParse(cartQte[i]) ?? 0;

      orderItems.add(OrderItem(
        productId: productId,
        quantity: quantity,
      ));
    }




    // Construct the Order object
    final order = Order(
      customerId: MyApp.userId.toString(),
      orderStatus: 'pending',
      totalAmount: totalAmount,
      orderItems: orderItems.isNotEmpty ? orderItems : null,
      createdAt: DateTime.now(),
    );

    try {
      // Send the request with proper JSON encoding and headers
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to create order: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $e')),
      );
    }
  }

  Future<void> fetchOrders() async {
    if (_isFetching) return; // Empêche plusieurs appels simultanés
    _isFetching = true;
    notifyListeners();
    

    try {
      String baseUrl =
          'http://localhost:3000/order'; // Change selon ton environnement
      final response = await http.get(Uri.parse(baseUrl));

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _orders = data
        .map((json) => Order.fromJson(json))
        .where((order) => order.customerId == MyApp.userId.toString())
        .toList();
      } else {
        print("Erreur API: ${response.statusCode}");
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      print("Erreur de récupération des factures: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
