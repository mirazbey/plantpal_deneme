// lib/models/plant_prediction.dart

class PlantPrediction {
  final String percentage;
  final String name;
  final String scientificName; // <-- BU SATIRI EKLE
  final String health;
  final String watering;
  final String advice;
  final String light;
  final String treatment;

  PlantPrediction({
    required this.percentage,
    required this.name,
    this.scientificName = '', // <-- CONSTRUCTOR'A EKLE (varsayılan değeri boş olsun)
    required this.health,
    required this.watering,
    required this.advice,
    required this.light,
    required this.treatment,
  });
}