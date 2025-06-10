// lib/models/place.dart

class Place {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String location;
  final String description;
  final double rating;
  final String? category; // Kategori null olabilir

  Place({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.location,
    required this.description,
    required this.rating,
    this.category,
  });

  // JSON'dan Place nesnesi oluşturmak için fabrika metodu
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List<dynamic>),
      location: json['location'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      category: json['category'] as String?,
    );
  }

  // Place nesnesini JSON'a dönüştürmek için metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrls': imageUrls,
      'location': location,
      'description': description,
      'rating': rating,
      'category': category,
    };
  }
}