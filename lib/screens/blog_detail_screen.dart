import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/models/blog.dart';
import 'package:intl/intl.dart'; // Tarih formatlamak için

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          blog.title,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                blog.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: AppColors.lightTextColor.withOpacity(0.3),
                  child: Center(
                    child: Icon(Icons.broken_image, size: 50, color: AppColors.lightTextColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${blog.author} - ${DateFormat('dd MMMM yyyy', 'tr_TR').format(blog.publishDate)}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32, color: AppColors.lightTextColor),
            Text(
              blog.content,
              style: TextStyle(
                fontSize: 17,
                height: 1.5,
                color: AppColors.textColor.withOpacity(0.9),
              ),
            ),
            if (blog.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Etiketler:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: blog.tags.map((tag) => Chip(
                  label: Text(tag, style: TextStyle(color: AppColors.white)),
                  backgroundColor: AppColors.primaryColor.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  labelStyle: const TextStyle(fontSize: 14),
                )).toList(),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}