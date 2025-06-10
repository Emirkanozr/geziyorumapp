class Blog {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime publishDate;
  final List<String> tags; // Etiketler (isteğe bağlı)

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.publishDate,
    this.tags = const [],
  });

  // Firestore veya başka bir JSON kaynağından veri okurken kullanılabilecek factory metodu
  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      author: json['author'] as String,
      publishDate: (json['publishDate'] as dynamic).toDate(), // Firestore Timestamp'i için .toDate()
      tags: List<String>.from(json['tags'] as List<dynamic>),
    );
  }

  // Veriyi JSON'a dönüştürürken kullanılabilecek metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'publishDate': publishDate,
      'tags': tags,
    };
  }
}