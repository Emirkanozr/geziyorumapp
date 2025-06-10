// lib/services/place_service.dart

import 'package:geziyorum/models/place.dart';

class PlaceService {
  // Şimdilik sahte (mock) verileri tutuyoruz. Gerçek bir uygulamada bir API'den gelecektir.
  static final List<Place> _mockPlaces = [
    Place(
      id: 'p1',
      name: 'Ayasofya',
      location: 'İstanbul',
      description: 'Bin yılı aşkın tarihiyle eşsiz bir ibadethane ve müze.',
      rating: 4.8,
      category: 'Tarihi Yer',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/a/a2/Hagia_Sophia_2022.jpg',
        'https://cdn.pixabay.com/photo/2020/02/05/17/04/hagia-sophia-4821817_1280.jpg',
        'https://cdn.pixabay.com/photo/2020/12/03/17/28/hagia-sophia-5799988_1280.jpg',
      ],
    ),
    Place(
      id: 'p2',
      name: 'Pamukkale',
      location: 'Denizli',
      description: 'Beyaz traverten terasları ve antik havuzlarıyla ünlü doğal güzellik.',
      rating: 4.9,
      category: 'Doğa Harikası',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/e/e0/Pamukkale_Travertines_from_North.jpg',
        'https://cdn.pixabay.com/photo/2016/11/08/04/47/pamukkale-1807357_1280.jpg',
        'https://cdn.pixabay.com/photo/2017/08/01/21/53/pamukkale-2566782_1280.jpg',
      ],
    ),
    Place(
      id: 'p3',
      name: 'Göreme Açık Hava Müzesi',
      location: 'Nevşehir',
      description: 'Kapadokya\'nın peri bacaları içinde oyulmuş kiliseleri ve manastırları.',
      rating: 4.7,
      category: 'Müzeler',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Goreme_Open_Air_Museum_01.jpg/1280px-Goreme_Open_Air_Museum_01.jpg',
        'https://cdn.pixabay.com/photo/2017/05/16/22/01/cappadocia-2319409_1280.jpg',
      ],
    ),
    Place(
      id: 'p4',
      name: 'Galata Kulesi',
      location: 'İstanbul',
      description: 'İstanbul\'un simgelerinden biri, muhteşem şehir manzarası sunar.',
      rating: 4.6,
      category: 'Tarihi Yer',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Galata_Tower_Istanbul.jpg/1280px-Galata_Tower_Istanbul.jpg',
        'https://cdn.pixabay.com/photo/2017/07/04/09/25/galata-tower-2470005_1280.jpg',
      ],
    ),
    Place(
      id: 'p5',
      name: 'Ölüdeniz',
      location: 'Muğla',
      description: 'Dünyaca ünlü lagünü ve yamaç paraşütü aktiviteleriyle bilinir.',
      rating: 4.9,
      category: 'Doğa Harikası',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Oludeniz_2021.jpg/1280px-Oludeniz_2021.jpg',
        'https://cdn.pixabay.com/photo/2015/09/02/12/35/turkey-918928_1280.jpg',
      ],
    ),
    Place(
      id: 'p6',
      name: 'Zeugma Mozaik Müzesi',
      location: 'Gaziantep',
      description: 'Antik Zeugma kentinden kurtarılan paha biçilmez mozaik koleksiyonlarına ev sahipliği yapar.',
      rating: 4.8,
      category: 'Müzeler',
      imageUrls: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Zeugma_Mosaik_M%C3%BCzesi_%282%29.jpg/1280px-Zeugma_Mosaik_M%C3%BCzesi_%282%29.jpg',
        'https://cdn.pixabay.com/photo/2017/05/11/17/57/mosaic-2305597_1280.jpg',
      ],
    ),
     Place(
      id: 'p7',
      name: 'Tarihi Yarımada Restoranları',
      location: 'İstanbul',
      description: 'Sultanahmet ve çevresindeki otantik Türk mutfağı lezzetleri.',
      rating: 4.5,
      category: 'Restoranlar',
      imageUrls: [
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/bb/11/a9/view-from-rooftop-terrace.jpg?w=1200&h=-1&s=1',
        'https://media-cdn.tripadvisor.com/media/photo-s/0e/21/fc/55/a-la-turca-restaurant.jpg',
      ],
    ),
    Place(
      id: 'p8',
      name: 'İstanbul Eğlence Mekanları',
      location: 'İstanbul',
      description: 'Beyoğlu ve Kadıköy\'deki canlı müzik, bar ve kulüp seçenekleri.',
      rating: 4.2,
      category: 'Eğlence',
      imageUrls: [
        'https://cdn.pixabay.com/photo/2016/11/23/15/48/audience-1854128_1280.jpg',
        'https://cdn.pixabay.com/photo/2016/11/22/19/23/bar-1850117_1280.jpg',
      ],
    ),
  ];

  Future<List<Place>> getAllPlaces() async {
    // Gerçek bir uygulamada burada bir API çağrısı olurdu
    await Future.delayed(const Duration(milliseconds: 500)); // Simüle edilmiş ağ gecikmesi
    return _mockPlaces;
  }

  Future<List<Place>> getPopularPlaces() async {
    // Şimdilik tüm mekanların en yüksek puanlı olanlarını popüler olarak kabul edelim.
    // Gerçek uygulamada popülerlik farklı kriterlere göre belirlenebilir (ziyaret sayısı, trendler vb.)
    await Future.delayed(const Duration(milliseconds: 700)); // Simüle edilmiş ağ gecikmesi
    _mockPlaces.sort((a, b) => b.rating.compareTo(a.rating)); // Puana göre azalan sıralama
    return _mockPlaces.take(5).toList(); // En popüler 5 mekanı döndür
  }

  // YENİ EKLENECEK METOT
  Future<List<Place>> getPlacesByCategory(String categoryName) async {
    await Future.delayed(const Duration(milliseconds: 700)); // Simüle edilmiş ağ gecikmesi
    if (categoryName == 'Tüm Kategoriler') { // "Tüm Kategoriler" seçeneği için
      return _mockPlaces;
    }
    return _mockPlaces
        .where((place) => place.category?.toLowerCase() == categoryName.toLowerCase())
        .toList();
  }

  // ID'ye göre tek bir mekan döndürme (PlaceDetailScreen için gerekebilir)
  Future<Place?> getPlaceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPlaces.firstWhere((place) => place.id == id);
  }
}