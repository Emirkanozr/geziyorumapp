// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider paketi import edildi
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/services/favorite_service.dart';
import 'package:geziyorum/widgets/place_card.dart';
import 'package:geziyorum/screens/main_screen.dart'; // mainScreenKey'i import etmek için

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FavoriteService'i dinleyerek favori listesindeki değişikliklere tepki ver
    // 'listen: true' varsayılandır, bu sayede notifyListeners() çağrıldığında bu widget yeniden inşa edilir.
    final favoriteService = Provider.of<FavoriteService>(context);
    final List<Place> favoritePlaces = favoriteService.favorites; // Anlık favori listesini al

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Favorilerim',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: favoritePlaces.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: AppColors.primaryColor.withOpacity(0.6)),
                    const SizedBox(height: 20),
                    const Text(
                      'Henüz favori mekanınız bulunmamaktadır.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Keşfetmeye başlayın ve beğendiklerinizi favorilerinize ekleyin!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.lightTextColor),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        // MainScreen'deki changeTab metodunu çağırarak Keşfet sekmesine geç
                        // Ana ekranınızdaki Keşfet sekmesinin indeksi 2 ise bu doğru.
                        // (Ana Sayfa: 0, Favoriler: 1, Keşfet: 2 varsayılarak)
                        mainScreenKey.currentState?.changeTab(2);
                      },
                      icon: const Icon(Icons.explore, color: AppColors.white),
                      label: const Text('Mekanları Keşfet', style: TextStyle(color: AppColors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoritePlaces.length,
              itemBuilder: (context, index) {
                final place = favoritePlaces[index];
                return Dismissible(
                  key: ValueKey(place.id), // Her öğe için benzersiz bir anahtar
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: AppColors.white, size: 30),
                  ),
                  confirmDismiss: (direction) async {
                    // Kullanıcıdan silme onayı al
                    return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Favoriden Kaldır?'),
                          content: Text('${place.name} favorilerinizden kaldırılacaktır.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal', style: TextStyle(color: AppColors.textColor)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Kaldır', style: TextStyle(color: AppColors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    // Onaylandıktan sonra favoriden kaldır
                    // Provider'dan alınan favoriteService'i kullanarak toggleFavorite çağır
                    await favoriteService.toggleFavorite(place);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${place.name} favorilerden başarıyla kaldırıldı.')),
                    );
                    // Dismissible widget'ı otomatik olarak kaldırılır,
                    // FavoriteService notifyListeners() çağrısı ile liste güncellenir.
                    // setState veya _favoritePlaces.removeAt(index) çağırmanıza gerek yok.
                  },
                  child: PlaceCard(place: place),
                );
              },
            ),
    );
  }
}