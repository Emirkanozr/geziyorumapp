// lib/widgets/recommended_place_card.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/screens/place_detail_screen.dart'; // Detay ekranına yönlendirme için

class RecommendedPlaceCard extends StatelessWidget {
  final Place place;

  const RecommendedPlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Container(
        width: 180, // Genişlik ayarlaması
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Hero(
                tag: 'recommended-${place.id}', // Benzersiz tag kullanın
                child: Image.network(
                  // BURAYI DÜZELTTİK: place.imageUrls[0] kullanılıyor.
                  // Ayrıca, liste boşsa placeholder resim gösteriliyor.
                  place.imageUrls.isNotEmpty ? place.imageUrls[0] : 'https://via.placeholder.com/180x120',
                  height: 100, // Resim yüksekliği
                  width: double.infinity, // Genişliği kapla
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.lightTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating gösterimi
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.secondaryAccentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toStringAsFixed(1), // rating'i burada göster
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}