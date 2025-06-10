import 'package:geziyorum/models/blog.dart';
import 'package:collection/collection.dart'; // <-- Bu satırı ekleyin

class BlogService {
  static final List<Blog> _mockBlogs = [
    Blog(
      id: 'b1',
      title: 'Kapadokya\'da Balon Turu Deneyimi',
      content: 'Kapadokya, benzersiz peri bacaları ve tarihi yerleşimleriyle Türkiye\'nin en büyüleyici bölgelerinden biridir. Özellikle gün doğumuyla birlikte yapılan balon turları, bu eşsiz coğrafyayı kuşbakışı görmek için harika bir fırsat sunar. Renkli balonların gökyüzünü süslediği o anlar, hayatınız boyunca unutamayacağınız bir deneyim vaat eder. Bu tur sırasında çektiğiniz fotoğraflar da anılarınızın en güzel parçası olacaktır.',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/09/08/04/39/hot-air-balloons-1653896_1280.jpg',
      author: 'Ayşe Yılmaz',
      publishDate: DateTime(2024, 10, 15),
      tags: ['Kapadokya', 'Balon Turu', 'Doğa', 'Macera'],
    ),
    Blog(
      id: 'b2',
      title: 'İstanbul\'un Gizli Kalmış Sokakları',
      content: 'İstanbul, her köşesi tarih kokan, keşfedilmeyi bekleyen bir şehir. Sadece bilinen turistik yerler değil, şehrin ara sokaklarında gizlenmiş küçük kafeler, butik dükkanlar ve tarihi yapılar da ziyaretçilerini bekliyor. Balat, Kuzguncuk gibi semtler, renkli evleri ve nostaljik atmosferleriyle fotoğraf çekmek için harika mekanlar sunar. Bu sokaklarda kaybolmak, İstanbul\'u yerel halkın gözünden deneyimlemek demektir.',
      imageUrl: 'https://cdn.pixabay.com/photo/2017/02/08/17/28/istanbul-2049969_1280.jpg',
      author: 'Mehmet Demir',
      publishDate: DateTime(2024, 9, 28),
      tags: ['İstanbul', 'Şehir Turu', 'Tarih', 'Keşif'],
    ),
    Blog(
      id: 'b3',
      title: 'Karadeniz\'in Yeşil Cenneti: Yayla Turizmi',
      content: 'Doğu Karadeniz, yemyeşil yaylaları, serin suları ve misafirperver insanlarıyla doğa severlerin gözdesi. Pokut Yaylası, Ayder Yaylası gibi yerler, bulutların üzerindeki evleriyle adeta bir tabloyu anımsatır. Bölgeye özgü lezzetleri tatmak, yöresel müzikleri dinlemek ve doğa yürüyüşleri yapmak, ruhunuzu dinlendirecek aktivitelerden bazılarıdır. Karadeniz\'de huzuru ve doğal güzelliği bir arada bulacaksınız.',
      imageUrl: 'https://cdn.pixabay.com/photo/2018/06/07/20/00/turkey-3460613_1280.jpg',
      author: 'Zeynep Can',
      publishDate: DateTime(2024, 11, 5),
      tags: ['Karadeniz', 'Yayla', 'Doğa', 'Huzur', 'Yeşil'],
    ),
    Blog(
      id: 'b4',
      title: 'Ege\'nin Berrak Suları ve Antik Kentleri',
      content: 'Türkiye\'nin batı kıyılarında yer alan Ege Bölgesi, masmavi denizi, altın rengi kumsalları ve binlerce yıllık antik kentleriyle tam bir tatil cenneti. İzmir, Bodrum, Marmaris gibi popüler destinasyonların yanı sıra, Efes, Bergama gibi antik kentler de tarih meraklılarını büyüler. Ege mutfağının enfes lezzetlerini tatmadan dönmeyin!',
      imageUrl: 'https://cdn.pixabay.com/photo/2021/08/21/08/29/ephesus-6562095_1280.jpg',
      author: 'Ali Veli',
      publishDate: DateTime(2024, 8, 12),
      tags: ['Ege', 'Deniz', 'Antik Kent', 'Tarih', 'Tatil'],
    ),
  ];

  Future<List<Blog>> getBlogs() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockBlogs;
  }

  Future<Blog?> getBlogById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBlogs.firstWhereOrNull((blog) => blog.id == id); // <-- Burası düzeltildi
  }
}