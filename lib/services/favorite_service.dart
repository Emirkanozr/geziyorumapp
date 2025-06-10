// lib/services/favorite_service.dart

import 'package:flutter/foundation.dart'; // ChangeNotifier için gerekli
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON işlemleri için
import 'package:geziyorum/models/place.dart'; // Place modelini import ediyoruz

class FavoriteService with ChangeNotifier {
  List<Place> _favorites = []; // Favori listesi önbelleği

  // favorites listesine dışarıdan erişim için getter
  List<Place> get favorites => _favorites;

  // Constructor: Servis oluşturulduğunda favorileri yükler
  FavoriteService() {
    _loadFavoritesFromPrefs();
  }

  // SharedPreferences'tan favori listesini yükler
  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJsonString = prefs.getString('favorites_list'); // Benzersiz bir anahtar kullanın
    
    if (favoritesJsonString != null && favoritesJsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(favoritesJsonString);
        _favorites = jsonList.map((jsonMap) => Place.fromJson(jsonMap as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Favoriler yüklenirken JSON ayrıştırma hatası: $e');
        _favorites = []; // Hata durumunda listeyi boşalt
      }
    } else {
      _favorites = []; // Kayıtlı favori yoksa veya boşsa boş liste
    }
    notifyListeners(); // Favoriler yüklendiğinde dinleyicilere haber ver
  }

  // Favori listesini SharedPreferences'a kaydeder
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> favoriteMaps = _favorites.map((place) => place.toJson()).toList();
    final String favoritesJsonString = json.encode(favoriteMaps);
    await prefs.setString('favorites_list', favoritesJsonString); // Aynı anahtarı kullanın
  }

  // Bir mekanın favorilerde olup olmadığını kontrol eder
  bool isFavorite(String placeId) {
    return _favorites.any((place) => place.id == placeId);
  }

  // Bir mekanı favorilere ekler veya favorilerden çıkarır
  Future<void> toggleFavorite(Place place) async {
    if (isFavorite(place.id)) {
      _favorites.removeWhere((item) => item.id == place.id);
    } else {
      _favorites.add(place);
    }
    await _saveFavoritesToPrefs(); // Değişiklikten sonra kaydet
    notifyListeners(); // Değişikliği dinleyicilere bildir
  }
}