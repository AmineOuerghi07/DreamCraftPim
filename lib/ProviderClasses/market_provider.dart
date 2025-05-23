import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/product.dart';

import 'package:http/http.dart' as http;

class MarketProvider extends ChangeNotifier {
  bool _isFilterActive = false;
  bool _changefilterIcon = false;
  bool _isCategoryFilterActive = false;
  bool _isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _searchTerm = '';
  String _category = '';

  String get category => _category;
  bool get changefilterIcon => _changefilterIcon;
  bool get isFilterActive => _isFilterActive;
  bool get isLoading => _isLoading;
  bool get isCategoryFilterActive => _isCategoryFilterActive;
  List<String> get categories => _categories;

  List<Product> get products =>
      _searchTerm.isEmpty ? _products : _filteredProducts;

  Future<List<Product>> get plantsProducts => _filterByCategory('plant');
  Future<List<Product>> get seedProducts => _filterByCategory('seeds');
  Future<List<Product>> get machineProducts => _filterByCategory('machines');

  Future<List<Product>> get pesticidesProducts => _filterByCategory('pesticides');
  Future<List<Product>> get fungicidesProducts => _filterByCategory('fungicides');
  Future<List<Product>> get herbicidesProducts => _filterByCategory('herbicides');

  final ApiService _apiService = ApiService();

  Future<void> fetchProducts() async {
    if (_products.isNotEmpty) return; // Prevent redundant API calls

    _isLoading = true;
    notifyListeners();

    try {
      _products = await _apiService.fetchProducts();
      _categories = _products
          .where((product) =>
              product.category != null && product.category!.isNotEmpty)
          .map((product) => product.category!)
          .toSet()
          .toList();
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFilter() {
    _isFilterActive = !_isFilterActive;
    notifyListeners();
  }

  void changeFilterIcon() {
    _changefilterIcon = !_changefilterIcon;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _category = category;

    notifyListeners();
  }

  void toggleCategoryFilter(String category) {
    if (_isCategoryFilterActive && _category == category) {
      _category = ''; // Reset category filter
      _isCategoryFilterActive = false;
    } else {
      _category = category;
      _isCategoryFilterActive = true;
    }
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    _filteredProducts = _products
        .where((product) =>
            product.name.toLowerCase().contains(term.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<List<Product>> _filterByCategory(String category) async {
    if (_isFilterActive) {
      final productsFromDatabase = await _apiService.fetchProductsfromDatabase();
      return productsFromDatabase.where((product) => product.category == category).toList();
    } else {
      return products;
    }
  }
}

class ApiService {

  final String baseUrl = "http://192.168.43.232:3000";

  Future<List<Product>> fetchProducts() async {
    final customerId = MyApp.userId.toString();
    final response = await http
        .get(Uri.parse('http://192.168.43.232:8000/recommend/$customerId'));

    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      try {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } catch (e) {
        print("Error decoding JSON: $e");
        rethrow;
      }
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<List<Product>> fetchProductsfromDatabase() async {
    final response = await http.get(Uri.parse('http://192.168.43.232:3000/product'));

    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      try {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } catch (e) {
        print("Error decoding JSON: $e");
        rethrow;
      }
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<Product> fetchProductById(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId'));

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product details');
    }
  }
}
