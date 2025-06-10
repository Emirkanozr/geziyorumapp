import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/blog.dart';
import 'package:geziyorum/services/blog_service.dart';
import 'package:geziyorum/screens/blog_detail_screen.dart'; // Blog detay ekranı için import
import 'package:intl/intl.dart'; // Tarih formatlamak için (pubspec.yaml'a intl paketi eklenmeli)

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final BlogService _blogService = BlogService();
  List<Blog> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    try {
      final blogs = await _blogService.getBlogs();
      if (mounted) {
        setState(() {
          _blogs = blogs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Bloglar yüklenirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloglar yüklenemedi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bloglar',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _blogs.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz blog gönderisi bulunamadı.',
                    style: TextStyle(fontSize: 18, color: AppColors.lightTextColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _blogs.length,
                  itemBuilder: (context, index) {
                    final blog = _blogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlogDetailScreen(blog: blog),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                blog.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: AppColors.lightTextColor.withOpacity(0.3),
                                  child: Center(
                                    child: Icon(Icons.broken_image, color: AppColors.lightTextColor),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    blog.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${blog.author} - ${DateFormat('dd MMMM yyyy', 'tr_TR').format(blog.publishDate)}', // Tarihi formatlama
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lightTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    blog.content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textColor.withOpacity(0.8),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (blog.tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: blog.tags.map((tag) => Chip(
                                        label: Text(tag, style: TextStyle(color: AppColors.white)),
                                        backgroundColor: AppColors.primaryColor.withOpacity(0.7),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        labelStyle: const TextStyle(fontSize: 12),
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}