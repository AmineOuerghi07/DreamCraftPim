import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Make sure you have a product model


class ProductDetailsProvider with ChangeNotifier {
  bool isLoading = true;
  Product? product;
  List<Product>? relatedProducts;
  int quantity = 1;

  // Constructor to initialize with a product ID (to fetch the product details)
  ProductDetailsProvider({required String productId}) {
    fetchProductDetails(productId);
    fetchRelatedProducts(productId);
  }

  // Fetch related products from the API
  Future<void> fetchRelatedProducts(String productId) async {
   
    try {
      isLoading = true;
      notifyListeners();
      // Here, replace with your actual API call
      final apiService = ApiService();
      relatedProducts = await apiService.fetchProductsfromDatabase().then((products) {
        return products.where((product) => product.category == this.product?.category && product.id != productId).toList();
      });
    } catch (e) {
      print('Error fetching product details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Fetch product details from the API
  Future<void> fetchProductDetails(String productId) async {
    try {
      isLoading = true;
      notifyListeners();
      // Here, replace with your actual API call
      final apiService = ApiService();
      product = await apiService.fetchProductsfromDatabase().then((products) {
        return products.firstWhere((product) => product.id == productId);
      });
    } catch (e) {
      print('Error fetching product details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

Future<void> checkSharedPref(Product product) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? cart = prefs.getStringList('cart');
  List<String>? cartQte = prefs.getStringList('cartQte');
  cart ??= [];
  cartQte ??= [];
  if (cart.contains(product.id)) {
    int index = cart.indexOf(product.id);
    cartQte[index] = (int.parse(cartQte[index]) + quantity).toString();
    await prefs.setStringList('cartQte', cartQte);
  } else {
    cartQte.add(quantity.toString());
    cart.add(product.id); 
  }
 
  await prefs.setStringList('cart', cart);
  await prefs.setStringList('cartQte', cartQte);
}

// Increment the quantity
void increment() {
  quantity++;
  notifyListeners();
}

// Decrement the quantity
void decrement() {
  if (quantity > 1) {
    quantity--;
  }
  notifyListeners();
}
}
