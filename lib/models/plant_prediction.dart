// lib/models/plant_prediction.dart (CORRECTED MODEL)

class PlantPrediction {
  final String name;
  final String scientificName;
  final String careSummary;
  final Map<String, String> careConditions;  // e.g., {'Güneş Işığı': 'Bol ışık ister...'}
  final Map<String, String> basicInfo;       // e.g., {'Aile': 'Papatyagiller'}
  final Map<String, String> characteristics; // e.g., {'Olgun Boyut': '30 cm'}

  PlantPrediction({
    required this.name,
    required this.scientificName,
    required this.careSummary,
    required this.careConditions,
    required this.basicInfo,
    required this.characteristics,
  });
}