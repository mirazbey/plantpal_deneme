// lib/models/article_model.dart (YENİ OLUŞTURULACAK DOSYA)

class Article {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath; // Makale için Unsplash arama kelimesi

  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}