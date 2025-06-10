import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/services/place_service.dart';

// Artık PlaceCard'ı kendi dosyasından import ediyoruz
import 'package:geziyorum/widgets/place_card.dart'; // <-- Bu satırı ekleyin
// import 'package:geziyorum/screens/home_screen.dart'; // <-- Bu satırı silin veya yorum satırı yapın

class CategoryPlacesScreen extends StatefulWidget {
  final String categoryName;

  const CategoryPlacesScreen({super.key, required this.categoryName});

  @override
  State<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends State<CategoryPlacesScreen> {
  final PlaceService _placeService = PlaceService();
  List<Place> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlacesByCategory();
  }

  Future<void> _loadPlacesByCategory() async {
    try {
      final places = await _placeService.getPlacesByCategory(widget.categoryName);
      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Kategoriye göre mekanlar yüklenirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekanlar yüklenemedi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _places.isEmpty
              ? Center(child: Text('${widget.categoryName} kategorisinde mekan bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return PlaceCard(place: place); // PlaceCard artık sorunsuz kullanılmalı
                  },
                ),
    );
  }
}