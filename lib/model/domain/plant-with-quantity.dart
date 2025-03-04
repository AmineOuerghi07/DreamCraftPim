import 'package:pim_project/model/domain/plant.dart';

class PlantWithQuantity {
  final Plant plant;
  final int totalQuantity;

  PlantWithQuantity({
    required this.plant,
    required this.totalQuantity,
  });

  factory PlantWithQuantity.fromJson(Map<String, dynamic> json) {
    return PlantWithQuantity(
      plant: Plant.fromJson(json['plant']),
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }
}