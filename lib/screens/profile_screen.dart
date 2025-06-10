// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geziyorum/services/auth_service.dart';
import 'package:geziyorum/services/user_data_service.dart';
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/screens/profile/edit_profile_screen.dart';
import 'package:geziyorum/screens/profile/settings_screen.dart';
import 'dart:async'; // StreamSubscription için
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  Map<String, dynamic>? _firestoreUserData;
  bool _isLoadingUserData = true;
  bool _isUploadingPhoto = false; // Profil fotoğrafı yükleme durumu
  StreamSubscription<User?>? _authStateSubscription; // authStateChanges için subscription
  StreamSubscription<Map<String, dynamic>?>? _userDataSubscription; // Firestore stream için subscription


  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeProfileData(); // Başlangıç verilerini yükle

    // Oturum değişikliklerini dinleyerek _currentUser'ı güncel tutma
    // Bu, kullanıcının oturumu kapattığında veya başka bir yerde değiştiğinde UI'ı günceller.
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != _currentUser) { // Sadece kullanıcı değiştiğinde veya null olduğunda işlem yap
        setState(() {
          _currentUser = user;
          _isLoadingUserData = user != null; // Kullanıcı varsa tekrar yüklemeye başla
          _firestoreUserData = null; // Eski veriyi temizle
        });
        if (user != null) {
          _loadUserData(user.uid); // Yeni kullanıcının verilerini yükle (ilk yükleme)
          _subscribeToUserDataStream(user.uid); // Yeni kullanıcının verilerini dinlemeye başla (gerçek zamanlı)
        } else {
          // Kullanıcı null olduysa (oturumu kapandıysa), stream'leri iptal et ve durumu sıfırla
          _userDataSubscription?.cancel();
          if(mounted) {
            setState(() {
              _isLoadingUserData = false; // Yükleme durumunu kapat
            });
          }
        }
      }
    });
  }

  // İlk yükleme ve RefreshIndicator için ayrı bir metod
  Future<void> _initializeProfileData() async {
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
      return;
    }
    // İlk yüklemede getOrCreateUserData ile veriyi bir kez çekip durumu ayarla
    await _loadUserData(_currentUser!.uid);
    // Sonra gerçek zamanlı dinlemeyi başlat
    _subscribeToUserDataStream(_currentUser!.uid);
  }

  // Firestore verisini gerçek zamanlı dinlemek için
  void _subscribeToUserDataStream(String uid) {
    _userDataSubscription?.cancel(); // Önceki stream'i iptal et
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    _userDataSubscription = userDataService.streamUserData(uid).listen((data) {
      if (mounted) {
        setState(() {
          _firestoreUserData = data;
          _isLoadingUserData = false; // Veri geldiyse yüklemeyi durdur
        });
      }
    }, onError: (error) {
      debugPrint('Firestore Stream Hatası: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil verileri güncellenirken hata oluştu: $error')),
        );
        setState(() {
          _isLoadingUserData = false; // Hata durumunda da yüklemeyi durdur
        });
      }
    });
  }

  // Kullanıcı verisini tek seferlik yükleme (RefreshIndicator gibi durumlar için)
  Future<void> _loadUserData(String uid) async {
    if (mounted) {
      setState(() {
        _isLoadingUserData = true;
      });
    }

    try {
      final userDataService = Provider.of<UserDataService>(context, listen: false);

      // getOrCreateUserData() ile çift sorguyu tek sorguda topluyor.
      _firestoreUserData = await userDataService.getOrCreateUserData(
        uid: uid,
        email: _currentUser?.email,
        displayName: _currentUser?.displayName,
        photoUrl: _currentUser?.photoURL,
      );

      // Eğer Firestore'dan veri gelmediyse ve Auth'ta hala bilgi varsa
      if (_firestoreUserData == null && _currentUser != null) {
         // Temel Auth bilgilerini kullanarak yine de bir şeyler göster
         _firestoreUserData = {
            'uid': uid,
            'email': _currentUser!.email,
            'name': _currentUser!.displayName?.split(' ').first ?? '',
            'surname': _currentUser!.displayName?.split(' ').skip(1).join(' ') ?? '',
            'photoURL': _currentUser!.photoURL,
            'bio': 'Henüz bir biyografi eklenmedi.',
            'phone': 'Ayarlanmadı',
         };
         debugPrint('Auth verileri kullanılarak geçici profil verisi oluşturuldu.');
      }

    } catch (e) {
      debugPrint('[_loadUserData] HATA OLUŞTU: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı verileri yüklenirken hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      // isLoadingUserData durumu StreamBuilder tarafından yönetileceği için,
      // bu finally bloğunda sadece hata durumunda false'a çekmeliyiz.
      // Normal akışta, Stream'den veri geldiğinde false olacak.
      // _firestoreUserData null ise isLoading = false yap ki boş ekran gelmesin
      if (mounted && _firestoreUserData != null) {
        setState(() {
          _isLoadingUserData = false;
        });
      } else if (mounted && _firestoreUserData == null) {
         // Eğer veri gelmediyse de yüklemeyi bitir.
         setState(() {
            _isLoadingUserData = false;
         });
      }
    }
  }

  Future<void> _signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signOut();
      // Oturum kapatıldığında otomatik olarak LoginScreen'e yönlendirilecektir
      // çünkü main.dart'taki StreamBuilder auth durumunu dinliyor.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oturum kapatılırken hata oluştu: ${e.toString()}')),
        );
      }
    }
  }

  // Profil fotoğrafını seçip Firebase Storage'a yükleyen ve kullanıcı verilerini güncelleyen yardımcı metot
  Future<void> _changeProfilePhoto() async {
    if (_currentUser == null || _isUploadingPhoto) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final File imageFile = File(pickedFile.path);
      final String fileExtension = pickedFile.path.split('.').last;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_currentUser!.uid}.$fileExtension');

      await storageRef.putFile(imageFile);
      final String downloadUrl = await storageRef.getDownloadURL();

      await _currentUser!.updatePhotoURL(downloadUrl);
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser;

      final userDataService = Provider.of<UserDataService>(context, listen: false);
      await userDataService.updateUserData(_currentUser!.uid, {'photoURL': downloadUrl});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf güncellenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel(); // Dinleyiciyi iptal et
    _userDataSubscription?.cancel(); // Dinleyiciyi iptal et
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 80, color: AppColors.lightTextColor),
                SizedBox(height: 20),
                Text(
                  'Kullanıcı bilgisi bulunamadı. Lütfen giriş yapın veya kaydolun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppColors.textColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String firstName = _firestoreUserData?['name'] ?? (_currentUser?.displayName?.split(' ').first ?? '...');
    String lastName = _firestoreUserData?['surname'] ?? (_currentUser?.displayName?.split(' ').skip(1).join(' ') ?? '...');
    String fullName = '$firstName $lastName'.trim();
    String email = _currentUser?.email ?? 'E-posta Bilinmiyor';
    String phone = _firestoreUserData?['phone'] ?? 'Ayarlanmadı';
    String bio = _firestoreUserData?['bio'] ?? 'Henüz bir biyografi eklenmedi.';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profilim',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.white),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              // EditProfileScreen'den dönüldüğünde _firestoreUserData'yı otomatik güncelleyecektir.
              // Çünkü streamUserData() ile gerçek zamanlı dinliyoruz.
              // Eğer stream'den emin olamazsak, manuel tekrar yükleme:
              // _loadUserData(_currentUser!.uid);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUserData(_currentUser!.uid), // Manuel yenilemede veriyi tekrar çek
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _changeProfilePhoto,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.accentColor,
                            backgroundImage: _currentUser?.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                                : null,
                            child: _currentUser?.photoURL == null
                                ? const Icon(Icons.person, size: 70, color: AppColors.white)
                                : null,
                          ),
                          if (_isUploadingPhoto)
                            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      fullName.isNotEmpty ? fullName : 'Kullanıcı Adı Bilinmiyor',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildInfoCard(
                context,
                title: 'Hakkımda',
                icon: Icons.info_outline,
                children: [
                  _buildProfileInfoRow(Icons.person_outline, 'Ad', firstName.isNotEmpty ? firstName : 'Ayarlanmadı'),
                  _buildProfileInfoRow(Icons.person_outline, 'Soyad', lastName.isNotEmpty ? lastName : 'Ayarlanmadı'),
                  _buildProfileInfoRow(Icons.phone_outlined, 'Telefon', phone),
                ],
              ),
              const SizedBox(height: 20),

              _buildInfoCard(
                context,
                title: 'Etkinliklerim',
                icon: Icons.local_activity_outlined,
                children: [
                  _buildInteractionItem(Icons.bookmark_border, 'Kaydedilen Geziler', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kaydedilen geziler özelliği yakında!')),
                    );
                  }),
                  _buildInteractionItem(Icons.rate_review_outlined, 'Yazdığım Yorumlar', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Yorumlarım özelliği yakında!')),
                    );
                  }),
                  _buildInteractionItem(Icons.photo_library_outlined, 'Fotoğraflarım', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fotoğraflarım özelliği yakında!')),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, color: AppColors.white),
                  label: const Text(
                    'Oturumu Kapat',
                    style: TextStyle(fontSize: 18, color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.lightTextColor, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.lightTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.lightTextColor, size: 18),
          ],
        ),
      ),
    );
  }
}