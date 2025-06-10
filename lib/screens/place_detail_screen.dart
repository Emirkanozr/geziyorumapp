// lib/screens/place_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/place.dart';
import 'package:geziyorum/services/favorite_service.dart';
import 'package:geziyorum/models/comment.dart';
import 'package:geziyorum/services/comment_service.dart';
import 'package:url_launcher/url_launcher.dart'; // URL açmak için
import 'package:uuid/uuid.dart'; // Benzersiz ID'ler için uuid paketi
import 'package:firebase_auth/firebase_auth.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  // Servisler ve Kontrolcüler
  final FavoriteService _favoriteService = FavoriteService();
  final CommentService _commentService = CommentService();
  final Uuid _uuid = const Uuid(); // Uuid nesnesini const yapabiliriz

  // Durum Değişkenleri
  bool _isFavorite = false;
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0.0; // Kullanıcının vereceği anlık puan
  List<Comment> _comments = []; // Mekana ait yorumlar
  double _averageRating = 0.0; // Mekanın ortalama puanı

  // Kullanıcının bu mekana daha önce yorum yapıp yapmadığını tutan değişken
  bool _userHasCommented = false;

  // Resim galerisi için PageController
  final PageController _pageController = PageController();
  int _currentImageIndex = 0; // Şu anki gösterilen resmin indeksi


  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus(); // Favori durumunu kontrol et
    _loadCommentsAndRating(); // Yorumları ve ortalama puanı yükle
    _checkUserCommentStatus(); // Kullanıcının yorum durumunu kontrol et
  }

  @override
  void dispose() {
    _commentController.dispose();
    _pageController.dispose(); // PageController'ı dispose et
    super.dispose();
  }

  // Favori durumunu kontrol eden ve güncelleyen metod
  void _checkFavoriteStatus() async {
    try {
      bool favorite = await _favoriteService.isFavorite(widget.place.id);
      if (mounted) {
        setState(() {
          _isFavorite = favorite;
        });
      }
    } catch (e) {
      debugPrint('Favori durumu kontrol edilirken hata oluştu: $e');
    }
  }

  // Favori durumunu değiştiren metod
  void _toggleFavorite() async {
    try {
      await _favoriteService.toggleFavorite(widget.place);
      _checkFavoriteStatus(); // Durumu güncelledikten sonra tekrar kontrol et
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? '${widget.place.name} favorilerden çıkarıldı.' : '${widget.place.name} favorilere eklendi!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Favori durumu değiştirilirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favori işlemi sırasında bir hata oluştu.')),
      );
    }
  }

  // Harita uygulamasını açma
  Future<void> _launchMapsUrl(String location) async {
    final String encodedLocation = Uri.encodeComponent(location);
    // Google Haritalar için genel URL
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation');
    // Apple Haritalar için genel URL (iOS cihazlar için)
    final Uri appleMapsUri = Uri.parse('https://maps.apple.com/?q=$encodedLocation');

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri);
    } else {
      // Hiçbir harita uygulaması açılamazsa kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita uygulaması açılamadı. Lütfen konum servislerini kontrol edin.')),
      );
    }
  }

  // Mekana ait yorumları ve ortalama puanı yükleme
  Future<void> _loadCommentsAndRating() async {
    try {
      final comments = await _commentService.getCommentsForPlace(widget.place.id);
      final avgRating = await _commentService.getAverageRatingForPlace(widget.place.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _averageRating = avgRating;
        });
      }
    } catch (e) {
      debugPrint('Yorumlar ve ortalama puan yüklenirken hata oluştu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumlar yüklenirken bir hata oluştu.')),
        );
      }
    }
  }

  // Kullanıcının bu mekana daha önce yorum yapıp yapmadığını kontrol etme
  Future<void> _checkUserCommentStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      final bool commented =
          await _commentService.hasUserCommentedForPlace(currentUser.uid, widget.place.id);
      if (mounted) {
        setState(() {
          _userHasCommented = commented;
        });
      }
    } catch (e) {
      debugPrint('Kullanıcının yorum durumu kontrol edilirken hata oluştu: $e');
    }
  }

  // Yorum ekleme işlemini yöneten metod
  void _addComment() async {
    if (_commentController.text.isEmpty || _currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yorumunuzu ve en az 1 yıldız puanınızı girin.')),
      );
      return;
    }

    if (_userHasCommented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu mekana zaten yorum yaptınız. Bir mekan için sadece bir yorum yapabilirsiniz.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum eklemek için giriş yapmalısınız.')),
      );
      return;
    }

    final newComment = Comment(
      id: _uuid.v4(), // Benzersiz ID oluştur
      placeId: widget.place.id,
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'Anonim',
      rating: _currentRating,
      text: _commentController.text,
      timestamp: DateTime.now(),
    );

    try {
      await _commentService.addComment(newComment);
      _commentController.clear(); // Metin kutusunu temizle
      if (mounted) {
        setState(() {
          _currentRating = 0.0; // Puanı sıfırla
          _userHasCommented = true; // Yorum yapıldı olarak işaretle
        });
      }
      _loadCommentsAndRating(); // Yorumları ve ortalama puanı yeniden yükle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorumunuz başarıyla eklendi!')),
      );
    } on Exception catch (e) {
      // CommentService'den gelen özel hatayı yakala ve kullanıcıya göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } catch (e) {
      debugPrint('Yorum eklenirken beklenmeyen hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum eklenirken beklenmeyen bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          widget.place.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : AppColors.white, // Favori rengi kırmızıya yakın
              size: 28,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
          ),
          const SizedBox(width: 8), // AppBar action'ları arasında boşluk
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mekan Resim Galerisi
            Stack(
              children: [
                Hero(
                  tag: widget.place.id,
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.place.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        // Resim URL'si boş veya geçersizse hata resmini göster
                        if (widget.place.imageUrls[index].isEmpty ||
                            !Uri.tryParse(widget.place.imageUrls[index])!.isAbsolute) {
                          return _buildErrorImage(250);
                        }
                        return Image.network(
                          widget.place.imageUrls[index],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              width: double.infinity,
                              color: AppColors.lightGray, // Yüklenirken arka plan
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
                          errorBuilder: (context, error, stackTrace) => _buildErrorImage(250),
                        );
                      },
                    ),
                  ),
                ),
                // Resim indikatörleri (sadece birden fazla resim varsa göster)
                if (widget.place.imageUrls.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.place.imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index ? AppColors.white : AppColors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mekan Adı
                  Text(
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Konum ve Rating
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 22, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.place.location,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textColor.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.star, size: 22, color: AppColors.secondaryAccentColor),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating.toStringAsFixed(1), // Puanı tek ondalık basamakla göster
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(${_comments.length} yorum)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kategori Bilgisi (Sadece varsa göster)
                  if (widget.place.category != null && widget.place.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 22, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            widget.place.category!,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textColor.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Açıklama Başlığı ve Metni
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.place.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor.withOpacity(0.9),
                      height: 1.6, // Satır aralığı
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),

                  // Ek Bilgiler (örnek olarak eklendi, gerçek verilerle değiştirilmeli)
                  const Text(
                    'Ek Bilgiler',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.access_time, 'Ziyaret Saatleri: 09:00 - 18:00'),
                  _buildInfoRow(Icons.money, 'Giriş Ücreti: 100 TL'),
                  _buildInfoRow(Icons.directions_car, 'Ulaşım: Toplu taşıma veya özel araç'),
                  const SizedBox(height: 30),

                  // Haritada Göster Butonu
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchMapsUrl(widget.place.location),
                      icon: const Icon(Icons.map, color: AppColors.white),
                      label: const Text(
                        'Haritada Göster',
                        style: TextStyle(fontSize: 18, color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Yorum ve Puan Bölümü Başlığı
                  const Text(
                    'Yorumlar ve Puanlar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Yeni Yorum Ekleme Alanı
                  _buildAddCommentSection(),
                  const SizedBox(height: 20),

                  // Mevcut Yorumları Listeleme
                  _buildCommentList(),

                  const SizedBox(height: 20), // En alt boşluk
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ek bilgi satırları için yardımcı metod
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: AppColors.textColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  // Yeni yorum ekleme bölümü widget'ı
  Widget _buildAddCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userHasCommented ? 'Bu mekana zaten yorum yaptınız.' : 'Yorum Yap ve Puan Ver',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _userHasCommented ? AppColors.lightTextColor : AppColors.textColor,
            ),
          ),
          const SizedBox(height: 15),
          // Puanlama yıldızları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _currentRating ? Icons.star : Icons.star_border,
                  color: AppColors.secondaryAccentColor,
                  size: 35,
                ),
                onPressed: _userHasCommented
                    ? null // Eğer yorum yapılmışsa butonu devre dışı bırak
                    : () {
                        setState(() {
                          _currentRating = (index + 1).toDouble();
                        });
                      },
              );
            }),
          ),
          const SizedBox(height: 15),
          // Yorum metni girişi
          TextField(
            controller: _commentController,
            maxLines: 3,
            enabled: !_userHasCommented, // Eğer yorum yapılmışsa TextField'ı devre dışı bırak
            decoration: InputDecoration(
              hintText: _userHasCommented ? 'Zaten yorum yaptınız.' : 'Yorumunuzu buraya yazın...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              fillColor: AppColors.lightGray,
              filled: true,
            ),
          ),
          const SizedBox(height: 15),
          // Yorum Ekle butonu
          Center(
            child: ElevatedButton(
              onPressed: _userHasCommented ? null : _addComment, // Eğer yorum yapılmışsa butonu devre dışı bırak
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('Yorum Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  // Mevcut yorumları listeleme bölümü widget'ı
  Widget _buildCommentList() {
    if (_comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Bu mekana henüz yorum yapılmamış. İlk yorumu siz yapın!',
            style: TextStyle(fontSize: 16, color: AppColors.textColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // SingleChildScrollView içinde kaydırmayı engeller
      shrinkWrap: true, // İçeriğine göre boyutlanır
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textColor),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < comment.rating ? Icons.star : Icons.star_border,
                          color: AppColors.secondaryAccentColor,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.text,
                  style: TextStyle(fontSize: 15, color: AppColors.textColor.withOpacity(0.9)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    // Tarih formatını iyileştirelim (örn: 07 Haziran 2025)
                    _formatDate(comment.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Resim yüklenemediğinde veya URL geçersizse gösterilecek widget
  Widget _buildErrorImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: height / 4, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            'Resim yüklenemedi',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Tarih formatlama yardımcı metodu
  String _formatDate(DateTime date) {
    // intl paketi ile Türkçe tarih formatlama için
    // main.dart'ta initializeDateFormatting('tr', null); çağrıldığından emin olun.
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}