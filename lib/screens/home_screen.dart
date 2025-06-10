// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors ve appTheme için
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/services/place_service.dart';

import 'package:geziyorum/screens/category_places_screen.dart';
import 'package:geziyorum/screens/search_screen.dart'; // Arama ekranı için

import 'package:geziyorum/widgets/place_card.dart'; // place_card.dart dosyasını import edin
import 'package:geziyorum/widgets/recommended_place_card.dart'; // recommended_place_card.dart dosyasını import edin

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaceService _placeService = PlaceService();
  List<Place> _popularPlaces = [];
  bool _isLoadingPopular = true;

  // Örnek kategori listesi
  final List<Map<String, dynamic>> _categories = const [ // const olarak işaretlendi
    {'name': 'Tarihi Yer', 'icon': Icons.castle},
    {'name': 'Doğa Harikası', 'icon': Icons.forest},
    {'name': 'Müzeler', 'icon': Icons.museum},
    {'name': 'Restoranlar', 'icon': Icons.restaurant},
    {'name': 'Eğlence', 'icon': Icons.local_activity},
  ];

  @override
  void initState() {
    super.initState();
    _loadPopularPlaces();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPopularPlaces() async {
    try {
      final places = await _placeService.getPopularPlaces();
      if (mounted) {
        setState(() {
          _popularPlaces = places;
          _isLoadingPopular = false;
        });
      }
    } catch (e) {
      debugPrint('Popüler mekanlar yüklenirken hata oluştu: $e'); // debugPrint kullanıldı
      if (mounted) {
        setState(() {
          _isLoadingPopular = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Popüler mekanlar yüklenemedi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar( // <-- AppBar geri eklendi
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Geziyorum',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white, size: 28),
            tooltip: 'Arama',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.white, size: 28),
            tooltip: 'Bildirimler',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirimler özelliği henüz geliştiriliyor!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Hoş Geldin Mesajı / Banner ---
              _buildWelcomeBanner(),
              const SizedBox(height: 30),

              // --- Kategoriler Bölümü ---
              const Text(
                'Kategorilere Göz At',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textColor),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 100, // Kategori kartları için sabit yükseklik
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(
                      category['name'] as String,
                      category['icon'] as IconData,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPlacesScreen(categoryName: category['name']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // --- Popüler Mekanlar Bölümü ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popüler Mekanlar',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textColor),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tüm mekanları listeleme özelliği geliştiriliyor!')),
                      );
                    },
                    child: const Text(
                      'Tümünü Gör',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _isLoadingPopular
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    )
                  : (_popularPlaces.isEmpty
                      ? const Center(child: Text('Popüler mekan bulunamadı.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _popularPlaces.length,
                          itemBuilder: (context, index) {
                            final place = _popularPlaces[index];
                            return PlaceCard(place: place);
                          },
                        )),

              const SizedBox(height: 30),

              // --- Size Özel Öneriler Bölümü ---
              const Text(
                'Size Özel Öneriler',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textColor),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 180,
                child: _isLoadingPopular
                    ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                    : (_popularPlaces.isEmpty
                        ? const Center(child: Text('Önerilen mekan bulunamadı.'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _popularPlaces.length,
                            itemBuilder: (context, index) {
                              final place = _popularPlaces[index];
                              return RecommendedPlaceCard(place: place);
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Widget'lar ---

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Yeni yerler keşfetmeye hazır mısın?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Türkiye\'nin dört bir yanındaki eşsiz mekanları keşfet!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.map, size: 50, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: AppColors.textColor, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}