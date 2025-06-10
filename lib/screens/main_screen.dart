// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:geziyorum/main.dart'; // AppColors ve appTheme için
import 'package:geziyorum/screens/home_screen.dart'; // Anasayfa
import 'package:geziyorum/screens/favorites_screen.dart'; // Favoriler ekranı
import 'package:geziyorum/screens/explore_screen.dart'; // Keşfet ekranı
import 'package:geziyorum/screens/profile_screen.dart'; // Profil ekranı
import 'package:geziyorum/screens/blog_screen.dart'; // Blog ekranı import edildi

// MainScreen için GlobalKey tanımla (Bu dışarıdan erişim için kalmalı)
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); 

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Seçili BottomNavigationBar öğesinin indeksi

  // Gösterilecek ekranların listesi
  // *** DEĞİŞİKLİK BURADA: 'const' anahtar kelimesi kaldırıldı ***
  final List<Widget> _screens = [ 
    const HomeScreen(), // Buradaki const'ları koruyabiliriz, basit widget'lar
    const FavoritesScreen(),
    const ExploreScreen(),
    const BlogScreen(),
    const ProfileScreen(), // Bu da const kalabilir ama hata verirse kaldırırız
  ];

  // Bu metodu public yapıyoruz ki dışarıdan erişilebilsin
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightTextColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: changeTab, // changeTab metodunu kullan
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Keşfet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}