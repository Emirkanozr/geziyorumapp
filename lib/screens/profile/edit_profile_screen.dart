// lib/screens/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Resim seçmek için
import 'package:firebase_storage/firebase_storage.dart'; // Resim yüklemek için
import 'dart:io'; // File işlemleri için
import 'package:geziyorum/main.dart'; // AppColors ve appTheme için
import 'package:geziyorum/services/user_data_service.dart'; // Firestore işlemler için

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validasyonu için
  User? _currentUser;

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;

  File? _pickedImage; // Seçilen resim dosyası
  String? _profileImageUrl; // Mevcut profil fotoğrafı URL'si (hem Auth'tan hem Firestore'dan)

  bool _isLoading = false; // Yükleme durumunu izlemek için

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // InitState'te mevcut kullanıcıyı al
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _phoneController = TextEditingController();

    // Mevcut kullanıcı bilgilerini Controller'lara yükle
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    // Sadece TEK BİR dispose metodu olmalı.
    // Bu metod, initState içinde başlatılan controller'ları dispose eder.
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    // Mevcut kullanıcı null ise işlem yapma
    if (_currentUser == null) {
      setState(() {
        _isLoading = false; // Yükleme durumunu kapat
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDataService = Provider.of<UserDataService>(context, listen: false);

      // Burası düzeltilen satır: getUserData metoduna UID parametresi gönderildi.
      final userData = await userDataService.getUserData(_currentUser!.uid); 

      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _surnameController.text = userData['surname'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _profileImageUrl = userData['photoURL'] ?? _currentUser?.photoURL; // Firestore'dan veya Auth'tan al (photoURL olarak güncellendi)
      } else {
        // Firestore'da veri yoksa Auth'taki bilgileri kullan
        String? displayName = _currentUser?.displayName; // Auth'tan displayName'i al

        if (displayName != null && displayName.isNotEmpty) {
          final nameParts = displayName.split(' ');
          _nameController.text = nameParts.first; // İlk kısım her zaman ad
          if (nameParts.length > 1) {
            _surnameController.text = nameParts.sublist(1).join(' '); // İkinci ve sonraki kısımlar soyad
          } else {
            _surnameController.text = ''; // Eğer soyadı yoksa boş bırak
          }
        } else {
          _nameController.text = ''; // DisplayName yoksa adı da boş bırak
          _surnameController.text = ''; // DisplayName yoksa soyadı da boş bırak
        }
        _profileImageUrl = _currentUser?.photoURL;
      }
    } catch (e) {
      debugPrint("Kullanıcı verileri yüklenirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı verileri yüklenirken bir hata oluştu.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Ya da ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Profil bilgilerini kaydetme fonksiyonu
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? newPhotoUrl = _profileImageUrl;

      // Eğer yeni bir resim seçildiyse, Firebase Storage'a yükle
      if (_pickedImage != null) {
        final String fileExtension = _pickedImage!.path.split('.').last;
        // Kullanıcıya özel klasörde (UID ile) resim sakla
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${_currentUser!.uid}.$fileExtension');

        // Yükleme işlemini gerçekleştir
        await storageRef.putFile(_pickedImage!);
        newPhotoUrl = await storageRef.getDownloadURL();
      }

      // Firebase Authentication'daki displayName ve photoURL'yi güncelle
      String newDisplayName = '${_nameController.text.trim()} ${_surnameController.text.trim()}'.trim();
      // displayName boşsa veya sadece boşluklardan oluşuyorsa güncelleme yapmama veya boş string atama
      if (newDisplayName.isNotEmpty) {
        await _currentUser!.updateDisplayName(newDisplayName);
      } else {
        await _currentUser!.updateDisplayName(''); // Boş bırakmak için
      }

      if (newPhotoUrl != null && newPhotoUrl != _currentUser!.photoURL) {
        await _currentUser!.updatePhotoURL(newPhotoUrl);
      }

      // Firestore'daki kullanıcı verilerini güncelle
      final userDataService = Provider.of<UserDataService>(context, listen: false);
      await userDataService.updateUserData(
        _currentUser!.uid, // UID'yi ilk parametre olarak gönder
        { // Tüm verileri Map olarak gönder
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'photoURL': newPhotoUrl, // Firestore'da da fotoğraf URL'sini sakla (anahtar 'photoURL' olmalı)
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
      // Başarılı olursa önceki ekrana dön
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      // Firebase'den gelen özel hataları yakala
      debugPrint('Firebase Hatası: ${e.code} - ${e.message}');
      String errorMessage = 'Bir Firebase hatası oluştu. Lütfen tekrar deneyin.';
      if (e.code == 'permission-denied') {
        errorMessage = 'Resim yükleme izni reddedildi. Lütfen Firebase Storage kurallarınızı kontrol edin.';
      } else if (e.code == 'storage/unauthorized') {
        errorMessage = 'Depolama erişiminiz yetersiz. Firebase Storage kurallarınızı kontrol edin.';
      } else if (e.code == 'storage/object-not-found') {
        errorMessage = 'Dosya bulunamadı veya silinmiş olabilir.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Diğer tüm hataları yakala
      debugPrint('Profil güncellenirken beklenmeyen bir hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellenirken bir hata oluştu: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil Düzenle'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const Center(
          child: Text('Kullanıcı bilgisi bulunamadı. Lütfen giriş yapın.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: AppColors.accentColor,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : null) as ImageProvider?,
                        child: _pickedImage == null && _profileImageUrl == null
                            ? const Icon(Icons.camera_alt, size: 80, color: AppColors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Adınız',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen adınızı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Soyadınız',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen soyadınızı girin.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numaranız',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      // Telefon numarası validasyonu eklenebilir
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save, color: AppColors.white),
                      label: const Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(fontSize: 18, color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
// test satırı
