// lib/widgets/place_card.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/screens/place_detail_screen.dart'; // Detay ekranına yönlendirme için

class PlaceCard extends StatelessWidget {
  final Place place;

  const PlaceCard({super.key, required this.place});

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
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: place.id, // Benzersiz tag kullanın
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // BURAYI DÜZELTTİK: place.imageUrl yerine place.imageUrls[0]
                  child: Image.network(
                    place.imageUrls.isNotEmpty ? place.imageUrls[0] : 'https://via.placeholder.com/100', // Boşsa placeholder
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppColors.lightTextColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            place.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.lightTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (place.category != null && place.category!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: AppColors.lightTextColor),
                          const SizedBox(width: 5),
                          Text(
                            place.category!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.lightTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 5), // Yeni eklenen boşluk
                    // Ortalama puanı buraya ekledik
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.secondaryAccentColor, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          place.rating.toStringAsFixed(1), // rating'i burada göster
                          style: TextStyle(
                            fontSize: 14,
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
      ),
    );
  }
}