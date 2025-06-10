// lib/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors için

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_applications, size: 80, color: AppColors.lightTextColor),
              const SizedBox(height: 20),
              Text(
                'Ayarlar ekranı yapım aşamasında!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Buraya bildirim ayarları, dil seçimi, tema ayarları gibi seçenekler eklenecek.',
                style: TextStyle(fontSize: 16, color: AppColors.lightTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}