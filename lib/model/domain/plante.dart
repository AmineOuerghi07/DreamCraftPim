class Plante {
  final String id;
  final String nom;
  final String type;
  final String season;
  final String description;
  final double temperature;
  final double humidity;
  final String image;
  final double waterAvg;

  Plante({
    required this.id,
    required this.nom,
    required this.type,
    required this.season,
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.image,
    required this.waterAvg,
  });
}