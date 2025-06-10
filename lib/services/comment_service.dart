import 'package:geziyorum/models/comment.dart';
// uuid paketi burada kullanılmıyor, Comment sınıfı içinde id oluşturuluyorsa veya başka bir yerden geliyorsa bu import'a CommentService'de gerek kalmaz.
// Ancak PlaceDetailScreen'de _uuid kullanıldığı için orada kalmalı.

class CommentService {
  static final List<Comment> _comments = []; // Yorumları bellekte tutan statik liste

  // Yeni yorum ekleme
  Future<void> addComment(Comment comment) async {
    // Burada aslında bir veritabanına veya API'ye kaydetme işlemi olurdu.
    // Ancak şimdilik listeye ekliyoruz.

    // Kullanıcının bu mekan için daha önce yorum yapıp yapmadığını kontrol et
    final bool hasCommented = await hasUserCommentedForPlace(comment.userId, comment.placeId);
    if (hasCommented) {
      // Eğer kullanıcı zaten yorum yapmışsa, bir hata fırlatabiliriz veya işlemi durdurabiliriz.
      // Bu örnekte bir Exception fırlatıyoruz.
      throw Exception('Bu mekan için zaten bir yorum yaptınız.');
    }

    _comments.add(comment);
    // Yorum eklendikten sonra listeyi güncel bir şekilde görmek için sıralayabilirim.
    _comments.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // En yeni yorumlar üstte
    await Future.delayed(const Duration(milliseconds: 100)); // Simüle edilmiş gecikme
  }

  // Belirli bir mekana ait yorumları getirme
  Future<List<Comment>> getCommentsForPlace(String placeId) async {
    final List<Comment> placeComments = _comments
        .where((comment) => comment.placeId == placeId)
        .toList();
    placeComments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await Future.delayed(const Duration(milliseconds: 200)); // Simüle edilmiş gecikme
    return placeComments;
  }

  // Bir mekanın ortalama puanını hesaplama
  Future<double> getAverageRatingForPlace(String placeId) async {
    final List<Comment> placeComments = await getCommentsForPlace(placeId);
    if (placeComments.isEmpty) {
      return 0.0; // Yorum yoksa 0 puan
    }
    double totalRating = 0;
    for (var comment in placeComments) {
      totalRating += comment.rating;
    }
    return totalRating / placeComments.length;
  }

  // Kullanıcının belirli bir mekan için yorum yapıp yapmadığını kontrol eden yeni metod
  Future<bool> hasUserCommentedForPlace(String userId, String placeId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simüle edilmiş gecikme
    return _comments.any((comment) => comment.userId == userId && comment.placeId == placeId);
  }

  // Debug için yorumları temizleme (Geliştirme aşamasında faydalı olabilir)
  void clearAllComments() {
    _comments.clear();
  }
}