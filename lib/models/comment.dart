class Comment {
  final String id;
  final String placeId; // Hangi mekana ait olduğunu belirtir
  final String userId; // Yorumu yapan kullanıcının ID'si (şimdilik mock olabilir)
  final String userName; // Yorumu yapan kullanıcının adı
  final double rating; // Puan (1-5 arası)
  final String text; // Yorum metni
  final DateTime timestamp; // Yorumun yapılma zamanı

  Comment({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.timestamp,
  });

  // Yorum nesnesini Map'e dönüştürme (Firebase için ileride faydalı olacak)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Tarihi string olarak sakla
    };
  }

  // Map'ten Yorum nesnesi oluşturma
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      placeId: map['placeId'],
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}