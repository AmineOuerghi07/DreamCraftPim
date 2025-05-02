import 'package:flutter/material.dart';
import 'package:pim_project/ProviderClasses/market_provider.dart';
import 'package:pim_project/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  bool isConfirmed = false;
  List<Product> cartItems = []; // Store cart items
  
  List<Product> get _products => cartItems;

  void toggleConfirmation(bool? value) {
    if (value == null) return; // Handle null case
    isConfirmed = value;
    notifyListeners();
  }

 Future<List<Product>> getcartProducts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? cart = prefs.getStringList('cart') ?? [];
  List<String>? cartQte = prefs.getStringList('cartQte') ?? [];

  ApiService apiService = ApiService();
  List<Product> products = await apiService.fetchProducts();

  List<Product> returnList = [];

  if (cart.isNotEmpty && cartQte.isNotEmpty) {  // ✅ Ensure lists are not null/empty
    for (int i = 0; i < products.length; i++) {
      if (cart!.contains(products[i].id)) {  // ✅ Use ! to indicate non-null
        Product _product = products[i];
        int index = cart!.indexOf(products[i].id);
        
        if (index < cartQte!.length) {  // ✅ Avoid out-of-bounds error
          _product.quantity = int.parse(cartQte![index]);
          returnList.add(_product);
        }
      }
    }
  }

  cartItems = returnList;  // Store in provider
  notifyListeners();  // Notify UI updates
  return returnList;
}

  Future<void> removeItem(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> cartQte = prefs.getStringList('cartQte') ?? [];

    if (cart.contains(product.id)) {
      int index = cart.indexOf(product.id);
      cart.removeAt(index);
      cartQte.removeAt(index);

      await prefs.setStringList('cart', cart);
      await prefs.setStringList('cartQte', cartQte);
    }

    // ✅ Remove from memory too
    cartItems.removeWhere((p) => p.id == product.id);

    notifyListeners(); // Notify UI update
  }
}
