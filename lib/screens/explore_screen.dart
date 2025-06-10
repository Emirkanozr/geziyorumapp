// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors'a erişmek için
import 'package:geziyorum/models/place.dart'; // Place modelini import ediyoruz
import 'package:geziyorum/screens/place_detail_screen.dart'; // Detay sayfasına yönlendirme için
import 'package:geziyorum/services/favorite_service.dart'; // FavoriteService'i import ediyoruz
import 'package:provider/provider.dart'; // Provider paketi import edildi

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // FavoriteService'i burada doğrudan oluşturmuyoruz.
  // Onun yerine build metodunda Provider.of<FavoriteService>(context) ile erişeceğiz.
  // final FavoriteService _favoriteService = FavoriteService(); // <-- Bu satırı siliyoruz

  // Geçici (mock) gezi noktaları verisi - tüm Türkiye'den örnekler
  final List<Place> _allPlaces = [
    Place(
      id: '1',
      name: 'Ayasofya Camii',
      imageUrls: ['https://images.unsplash.com/photo-1587609277646-a496b8c8d8b1?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'İstanbul, Türkiye',
      description: 'Binlerce yıllık tarihi ve büyüleyici mimarisiyle İstanbul\'un kalbi.',
      rating: 4.9,
      category: 'Tarihi Yer',
    ),
    Place(
      id: '2',
      name: 'Pamukkale Travertenleri',
      imageUrls: ['https://images.unsplash.com/photo-1549646875-99ee8b89e3f8?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Denizli, Türkiye',
      description: 'Termal suların oluşturduğu bembeyaz teraslar, UNESCO Dünya Mirası.',
      rating: 4.8,
      category: 'Doğa Harikası',
    ),
    Place(
      id: '3',
      name: 'Kapadokya Peribacaları',
      imageUrls: ['https://images.unsplash.com/photo-1605380590308-f4632b8f8e83?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Nevşehir, Türkiye',
      description: 'Eşsiz coğrafi oluşumlar ve sıcak hava balonu deneyimi.',
      rating: 4.9,
      category: 'Doğa Harikası',
    ),
    Place(
      id: '4',
      name: 'Antalya Kaleiçi',
      imageUrls: ['https://images.unsplash.com/photo-1627883398939-2a91266b7c7b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Antalya, Türkiye',
      description: 'Tarihi evler, dar sokaklar ve Akdeniz esintisi.',
      rating: 4.6,
      category: 'Tarihi Yer',
    ),
    Place(
      id: '5',
      name: 'Uzungöl',
      imageUrls: ['https://images.unsplash.com/photo-1616875225139-4d8e785539d0?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Trabzon, Türkiye',
      description: 'Doğa harikası göl ve yemyeşil ormanlar.',
      rating: 4.7,
      category: 'Doğa Harikası',
    ),
    Place(
      id: '6',
      name: 'Ölüdeniz',
      imageUrls: ['https://images.unsplash.com/photo-1619420606342-998845e2cf99?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Muğla, Türkiye',
      description: 'Mavinin en güzel tonları, yamaç paraşütünün kalbi.',
      rating: 4.9,
      category: 'Plaj',
    ),
    Place(
      id: '7',
      name: 'Nemrut Dağı',
      imageUrls: ['https://images.unsplash.com/photo-1605380590308-f4632b8f8e83?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Adıyaman, Türkiye',
      description: 'Kommagene Krallığı\'ndan kalma dev heykellerin bulunduğu UNESCO Dünya Mirası alanı.',
      rating: 4.5,
      category: 'Tarihi Yer',
    ),
    Place(
      id: '8',
      name: 'Sümela Manastırı',
      imageUrls: ['https://images.unsplash.com/photo-1549646875-99ee8b89e3f8?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Trabzon, Türkiye',
      description: 'Sarp bir kayalığın üzerine inşa edilmiş tarihi Rum Ortodoks manastırı.',
      rating: 4.7,
      category: 'Tarihi Yer',
    ),
    Place(
      id: '9',
      name: 'Göbeklitepe',
      imageUrls: ['https://images.unsplash.com/photo-1627883398939-2a91266b7c7b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'Şanlıurfa, Türkiye',
      description: 'İnsanlık tarihinin bilinen en eski tapınak yapısı, UNESCO Dünya Mirası.',
      rating: 4.9,
      category: 'Tarihi Yer',
    ),
    Place(
      id: '10',
      name: 'İzmir Saat Kulesi',
      imageUrls: ['https://images.unsplash.com/photo-1549646875-99ee8b89e3f8?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'İzmir, Türkiye',
      description: 'İzmir\'in Konak Meydanı\'nda bulunan tarihi saat kulesi.',
      rating: 4.2,
      category: 'Mimari',
    ),
    Place(
      id: '11',
      name: 'Boğaziçi Köprüsü',
      imageUrls: ['https://images.unsplash.com/photo-1587609277646-a496b8c8d8b1?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'],
      location: 'İstanbul, Türkiye',
      description: 'Asya ve Avrupa\'yı birbirine bağlayan ikonik köprü.',
      rating: 4.8,
      category: 'Mimari',
    ),
    Place(
      id: '12',
      name: 'Neolokal',
      imageUrls: ['https://via.placeholder.com/150/FF5733/FFFFFF?text=Neolokal'], // Geçici resim
      location: 'İstanbul, Türkiye',
      description: 'Anadolu mutfağına çağdaş bir yorum getiren ödüllü restoran.',
      rating: 4.7,
      category: 'Restoran',
    ),
    Place(
      id: '13',
      name: 'MOC İstanbul',
      imageUrls: ['https://via.placeholder.com/150/33FF57/FFFFFF?text=MOC'], // Geçici resim
      location: 'İstanbul, Türkiye',
      description: 'Nitelikli kahveleriyle ünlü popüler bir kahveci.',
      rating: 4.5,
      category: 'Kafe',
    ),
    Place(
      id: '14',
      name: 'Zeugma Mozaik Müzesi',
      imageUrls: ['https://via.placeholder.com/150/5733FF/FFFFFF?text=Zeugma'], // Geçici resim
      location: 'Gaziantep, Türkiye',
      description: 'Dünyanın en büyük mozaik müzelerinden biri.',
      rating: 4.8,
      category: 'Müze',
    ),
  ];

  List<Place> _filteredPlaces = [];
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;

  // Tüm kategorileri dinamik olarak çekmek için
  List<String> get _allCategories {
    return _allPlaces
        .map((place) => place.category)
        .where((category) => category != null)
        .map((category) => category!)
        .toSet()
        .toList()
          ..sort();
  }

  // Tüm şehirleri dinamik olarak çekmek için
  List<String> get _allCities {
    return _allPlaces.map((place) => place.location.split(',')[0].trim()).toSet().toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    // Başlangıçta tüm yerleri göster
    _applyFilters(); // initState'de filtreleme metodunu çağırıyoruz

    // Arama kutusundaki değişiklikleri dinle
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters); // Listener'ı temizle
    _searchController.dispose();
    super.dispose();
  }

  // Arama ve filtreleme işlevini birleştiren tek metod
  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    final filtered = _allPlaces.where((place) {
      final nameLower = place.name.toLowerCase();
      final descriptionLower = place.description.toLowerCase();
      final locationLower = place.location.toLowerCase();
      final categoryLower = place.category?.toLowerCase() ?? '';

      final matchesSearchQuery = query.isEmpty ||
          nameLower.contains(query) ||
          locationLower.contains(query) ||
          descriptionLower.contains(query);

      final matchesCategory = _selectedCategory == null || categoryLower == _selectedCategory!.toLowerCase();

      final placeCity = place.location.split(',')[0].trim().toLowerCase();
      final matchesCity = _selectedCity == null || placeCity == _selectedCity!.toLowerCase();

      return matchesSearchQuery && matchesCategory && matchesCity;
    }).toList();

    setState(() {
      _filteredPlaces = filtered;
    });
  }

  /// Filtreleri sıfırlayan metod
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedCity = null;
    });
    _applyFilters(); // Filtreleri sıfırladıktan sonra listeyi güncelle
  }

  @override
  Widget build(BuildContext context) {
    // FavoriteService'i Provider aracılığıyla dinleyin
    // listen: true olduğunda, FavoriteService'te notifyListeners() çağrıldığında
    // bu widget'ın build metodu yeniden çalışır ve favori butonları güncellenir.
    final favoriteService = Provider.of<FavoriteService>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Keşfet',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            tooltip: 'Filtreleri Sıfırla',
            onPressed: _resetFilters, // Şimdi bu metod tanımlı
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Şehir, yer veya açıklama ara...',
                hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textColor.withOpacity(0.6)),
                        onPressed: () {
                          _searchController.clear();
                          // Listener zaten _applyFilters'ı çağıracak, burada tekrar gerek yok
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
              style: TextStyle(color: AppColors.textColor),
              // onChanged artık _searchController.addListener tarafından yönetiliyor
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedCategory,
                    hint: Text('Kategori Seç', style: TextStyle(color: AppColors.textColor.withOpacity(0.7))),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Tümü', style: TextStyle(color: AppColors.textColor))),
                      ..._allCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category, style: TextStyle(color: AppColors.textColor)),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _applyFilters();
                    },
                    dropdownColor: AppColors.white,
                    iconEnabledColor: AppColors.primaryColor,
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedCity,
                    hint: Text('Şehir Seç', style: TextStyle(color: AppColors.textColor.withOpacity(0.7))),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Tümü', style: TextStyle(color: AppColors.textColor))),
                      ..._allCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city, style: TextStyle(color: AppColors.textColor)),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                      _applyFilters();
                    },
                    dropdownColor: AppColors.white,
                    iconEnabledColor: AppColors.primaryColor,
                    style: TextStyle(color: AppColors.textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _filteredPlaces.isEmpty
                  ? Center(
                      child: Text(
                        'Aradığınız kriterlere uygun mekan bulunamadı.',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _filteredPlaces[index];
                        // FavoriteService'i kullanarak favori durumunu anlık kontrol et
                        final isCurrentlyFavorite = favoriteService.isFavorite(place.id);

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceDetailScreen(place: place),
                              ),
                            );
                            // Detay ekranından dönüldüğünde favori durumu otomatik güncellenecek
                            // çünkü ExploreScreen'daki FavoriteService'ı dinliyoruz.
                            // Bu setState, eğer Detay ekranında Place nesnesi üzerinde
                            // favori dışında başka bir değişiklik olsaydı gerekli olabilirdi.
                            // Favori için artık otomatik.
                            // setState(() {});
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Hero(
                                          tag: place.id,
                                          child: Image.network(
                                            place.imageUrls[0],
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? (loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!)
                                                        : null,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          place.location,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textColor.withOpacity(0.8),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.star, color: AppColors.secondaryAccentColor, size: 18),
                                            const SizedBox(width: 5),
                                            Text(
                                              place.rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                            // Favori Butonu (Güncellenmiş)
                                            const Spacer(), // Alan bırakır
                                            IconButton(
                                              icon: Icon(
                                                isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
                                                color: isCurrentlyFavorite ? Colors.red : AppColors.primaryColor,
                                                size: 24,
                                              ),
                                              onPressed: () async {
                                                // toggleFavorite, FavoriteService'te notifyListeners() çağıracağı için
                                                // bu widget otomatik olarak yeniden inşa edilecek ve ikon güncellenecek.
                                                await favoriteService.toggleFavorite(place);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isCurrentlyFavorite ? '${place.name} favorilerden çıkarıldı.' : '${place.name} favorilere eklendi!',
                                                    ),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8), // Yıldız ve favori butonu ile açıklama arasına boşluk
                                        Text(
                                          place.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textColor.withOpacity(0.7),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}