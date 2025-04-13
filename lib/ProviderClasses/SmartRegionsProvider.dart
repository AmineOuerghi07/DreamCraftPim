import 'package:flutter/material.dart';

class SmartRegionsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cardsData = [
    {
      "icon": Icons.lightbulb,
      "iconColor": Colors.yellow,
      "title": "Lighting",
      "subtitle": "12 watt",
    },
    {
      "icon": Icons.thermostat,
      "iconColor": Colors.red,
      "title": "Temperature",
      "subtitle": "40°C",
    },
    {
      "icon": Icons.water_drop,
      "iconColor": Colors.blue,
      "title": "Irrigation",
      "subtitle": "100m",
    },
    {
      "icon": Icons.landscape_rounded,
      "iconColor": const Color.fromARGB(255, 172, 109, 15),
      "title": "Soil",
      "subtitle": "Growth",
    },
  ];

  List<Map<String, dynamic>> get cardsData => _cardsData;

  final List<bool> _switches = List.generate(4, (index) => true);
  
  List<bool> get switches => _switches;

  void toggleSwitch(int index, bool value) {
    _switches[index] = value;
    notifyListeners();
  }
}
