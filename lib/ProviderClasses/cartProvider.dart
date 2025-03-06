import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  bool isConfirmed = false;
  List<Product> cartItems = []; // Store cart items

  void toggleConfirmation(bool value) {
    isConfirmed = value;
    notifyListeners();
  }

  Future<List<Product>> getcartProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cart = prefs.getStringList('cart');
    List<String>? cartQte = prefs.getStringList('cartQte');

    ApiService apiService = ApiService();
    List<Product> products = await apiService.fetchProducts();

    List<Product> returnList = [];

    if (cart != null && cartQte != null) {
      for (int i = 0; i < products.length; i++) {
        if (cart.contains(products[i].id)) {
          Product _product = products[i];
          _product.quantity = int.parse(cartQte[cart.indexOf(products[i].id)]);
          returnList.add(_product);
        }
      }
    }

    cartItems = returnList; // Store in provider
    notifyListeners(); // Notify UI updates
    return returnList;
  }
}
