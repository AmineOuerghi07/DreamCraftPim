// model/domain/plant-with-quantity.dart
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
      plant: Plant.fromJson(json['plant'] is String ? {'_id': json['plant']} : json['plant']),
      totalQuantity: json['totalQuantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'plant': plant.toJson(), // Assuming Plant has a toJson method
        'quantity': totalQuantity, // Match backend field name
      };

      @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantWithQuantity &&
          runtimeType == other.runtimeType &&
          plant == other.plant &&
          totalQuantity == other.totalQuantity;

  @override
  int get hashCode => plant.hashCode ^ totalQuantity.hashCode;
}