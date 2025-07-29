// lib/services/discover_data_service.dart (YENİ OLUŞTURULACAK DOSYA)

import 'package:plantpal/models/article_model.dart';
import 'package:plantpal/pages/plant_search_page.dart'; // PlantSearchResult modelini kullanmak için

class DiscoverDataService {
  // Popüler bitkiler listesini döndüren fonksiyon
  static List<PlantSearchResult> getPopularPlants() {
    return [
      PlantSearchResult(commonName: 'Devetabanı', scientificName: 'Monstera deliciosa', imagePath: 'Monstera deliciosa'),
      PlantSearchResult(commonName: 'Paşa Kılıcı', scientificName: 'Sansevieria trifasciata', imagePath: 'Sansevieria trifasciata'),
      PlantSearchResult(commonName: 'Orkide', scientificName: 'Orchidaceae', imagePath: 'Orchid flower'),
      PlantSearchResult(commonName: 'Sukulent', scientificName: 'Succulent', imagePath: 'Succulent plant'),
    ];
  }

  // lib/services/discover_data_service.dart dosyasında sadece bu fonksiyonu değiştirin

// lib/services/discover_data_service.dart dosyasında sadece bu fonksiyonu değiştirin

static List<Article> getArticles() {
  return [
    // DÜZELTME: 'const' eklendi
    const Article(
      id: '1',
      title: 'Yapraklar Neden Sararır?',
      subtitle: 'En yaygın sebepler ve pratik çözümleri',
      imagePath: 'yellow leaves on plant',
    ),
    // DÜZELTME: 'const' eklendi
    const Article(
      id: '2',
      title: 'Yeni Başlayanlar İçin 5 İdeal Bitki',
      subtitle: 'Bakımı kolay, dayanıklı ve şık seçenekler',
      imagePath: 'easy care houseplants',
    ),
    // DÜZELTME: 'const' eklendi
    const Article(
      id: '3',
      title: 'Saksı Değişimi Zamanı Geldi mi?',
      subtitle: 'Bitkinizin sağlığı için doğru zamanlama',
      imagePath: 'repotting plant',
    ),
  ];
}
}