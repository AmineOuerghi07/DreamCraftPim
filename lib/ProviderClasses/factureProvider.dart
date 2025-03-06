import 'package:flutter/material.dart';

class FactureProvider extends ChangeNotifier {
  bool editMode = false;

  void toggleEditMode() {
    editMode = !editMode;
    notifyListeners();
  }
}
