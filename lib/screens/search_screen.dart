// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/services/place_service.dart';
import 'package:geziyorum/widgets/place_card.dart';

// String uzantısı: Arama için Türkçe karakterleri normalleştirir
// Bu sayede hem kullanıcı "i" veya "ı" yazsa da, hem de mekan adı "İ" veya "I" içerse de eşleşme sağlanır.
extension StringSearchExtension on String {
  String toNormalizedLowerCase() {
    return this
        .replaceAll('İ', 'i') // Büyük İ -> küçük i (noktalı)
        .replaceAll('I', 'i') // Büyük I (noktasız) -> küçük i (noktalı)
        .replaceAll('ı', 'i') // Küçük ı (noktasız) -> küçük i (noktalı)
        .replaceAll('Ş', 's') // Ş -> s
        .replaceAll('ş', 's') // ş -> s
        .replaceAll('Ç', 'c') // Ç -> c
        .replaceAll('ç', 'c') // ç -> c
        .replaceAll('Ğ', 'g') // Ğ -> g
        .replaceAll('ğ', 'g') // ğ -> g
        .replaceAll('Ü', 'u') // Ü -> u
        .replaceAll('ü', 'u') // ü -> u
        .replaceAll('Ö', 'o') // Ö -> o
        .replaceAll('ö', 'o') // ö -> o
        .toLowerCase(); // Son olarak tüm metni küçük harfe çevir
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PlaceService _placeService = PlaceService();
  List<Place> _allPlaces = []; // Tüm mekanları tutacak liste
  List<Place> _filteredPlaces = []; // Filtrelenmiş mekanları tutacak liste
  bool _isLoading = true; // Veri yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _loadAllPlaces(); // Ekran açıldığında tüm mekanları yükle
    _searchController.addListener(_onSearchChanged); // Arama kutusundaki değişiklikleri dinle
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Tüm mekanları PlaceService'ten asenkron olarak yükleyen metod
  Future<void> _loadAllPlaces() async {
    try {
      final places = await _placeService.getAllPlaces();
      if (mounted) { // Widget hala ağaçta mı kontrolü
        setState(() {
          _allPlaces = places;
          // Başlangıçta arama çubuğu boşken veya yeni yüklendiğinde tüm mekanları göster
          _filteredPlaces = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Mekanlar yüklenirken hata oluştu: $e'); // Hata çıktısı
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekanlar yüklenemedi. Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  // Arama metni değiştiğinde filtreleme yapan metod
  void _onSearchChanged() {
    // Arama sorgusunu normalleştirilmiş küçük harfe çevir ve baştaki/sondaki boşlukları kaldır
    final query = _searchController.text.toNormalizedLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        // Arama sorgusu boşsa, tüm mekanları göster (veya hiçbir şey gösterme, tercihe bağlı)
        _filteredPlaces = _allPlaces;
      } else {
        // Arama sorgusu varsa, mekanları filtrele
        _filteredPlaces = _allPlaces.where((place) {
          // Mekan verilerini de aynı normalleştirilmiş küçük harf forma getir
          final placeNameNormalized = place.name.toNormalizedLowerCase();
          final placeLocationNormalized = place.location.toNormalizedLowerCase();
          final placeCategoryNormalized = place.category?.toNormalizedLowerCase() ?? ''; // Kategori yoksa boş string

          // Arama sorgusunun mekan adı, konum veya kategori içinde geçip geçmediğini kontrol et
          return placeNameNormalized.contains(query) ||
                 placeLocationNormalized.contains(query) ||
                 placeCategoryNormalized.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Ekran açıldığında klavye otomatik açılsın
          style: const TextStyle(color: AppColors.white, fontSize: 18),
          cursorColor: AppColors.white,
          decoration: InputDecoration(
            hintText: 'Mekan adı, konum veya kategori ara...',
            hintStyle: TextStyle(color: AppColors.white.withOpacity(0.7)),
            border: InputBorder.none, // Kenarlık yok
            suffixIcon: _searchController.text.isNotEmpty // Metin varsa temizle butonu göster
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.white),
                    onPressed: () {
                      _searchController.clear(); // Metni temizle
                      // _onSearchChanged metodu addListener sayesinde otomatik olarak tekrar çalışır
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _isLoading // Yükleniyorsa
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _filteredPlaces.isEmpty && _searchController.text.isNotEmpty // Sonuç yok ve arama boş değilse
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      '\'${_searchController.text}\' için sonuç bulunamadı.\nLütfen farklı bir arama deneyin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.textColor.withOpacity(0.7)),
                    ),
                  ),
                )
              : _filteredPlaces.isEmpty && _searchController.text.isEmpty && !_isLoading // Arama boş ve genel olarak hiç mekan yoksa
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Henüz yüklenecek mekan bulunamadı. Lütfen daha sonra tekrar deneyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: AppColors.textColor.withOpacity(0.7)),
                        ),
                      ),
                    )
                  : ListView.builder( // Sonuçlar varsa listele
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _filteredPlaces[index];
                        return PlaceCard(place: place);
                      },
                    ),
    );
  }
}