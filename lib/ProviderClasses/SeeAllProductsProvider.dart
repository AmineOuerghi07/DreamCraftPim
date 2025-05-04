import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/model/product.dart';

class SeeAllProductsProvider extends ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products; // Public getter for UI access

  Future<void> getProducts(String category) async {
    ApiService apiService = ApiService();
    List<Product> allProducts = await apiService.fetchProducts(); // Await the API call

    _products = allProducts.where((product) => product.category == category).toList();

    notifyListeners(); // Notify the UI
  }
}
