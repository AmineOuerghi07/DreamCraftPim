import 'package:flutter/material.dart';
import 'package:pim_project/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FactureProvider extends ChangeNotifier {
  bool editMode = false;
  int? selectedRowIndex;
  List<Map<String, dynamic>> _products = [];

  List<Map<String, dynamic>> get products => _products;

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

  
}
