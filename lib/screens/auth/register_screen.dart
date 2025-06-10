// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geziyorum/services/auth_service.dart'; // AuthService'i import et
import 'package:geziyorum/main.dart'; // AppColors için
import 'package:geziyorum/screens/auth/login_screen.dart'; // LoginScreen'e geçiş için

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifreler uyuşmuyor.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _surnameController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hesabınız başarıyla oluşturuldu!')),
        );
      } on AuthException catch (e) {
        String errorMessage = 'Kayıt olurken bir hata oluştu: ${e.message}';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta formatı.';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beklenmedik bir hata oluştu: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Kayıt Ol',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 80, color: AppColors.primaryColor),
                const SizedBox(height: 30),

                // AD TEXTFIELD
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Adınız',
                    hintText: 'adınızı girin',
                    prefixIcon: const Icon(Icons.person, color: AppColors.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // SOYAD TEXTFIELD
                TextFormField(
                  controller: _surnameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Soyadınız',
                    hintText: 'soyadınızı girin',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mevcut E-POSTA TEXTFIELD
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'e-postanızı girin',
                    prefixIcon: const Icon(Icons.email, color: AppColors.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin.';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Geçerli bir e-posta adresi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    hintText: 'şifrenizi girin',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.lightTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin.';
                    }
                    // YENİ ŞİFRE KARMAŞIKLIĞI KONTROLLERİ BURADA BAŞLAR
                    if (value.length < 8) {
                      return 'Şifre en az 8 karakter olmalıdır.';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Şifre en az bir büyük harf içermelidir.';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Şifre en az bir küçük harf içermelidir.';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Şifre en az bir rakam içermelidir.';
                    }
                    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      return 'Şifre en az bir özel karakter (!@#\$%^&*) içermelidir.';
                    }
                    // YENİ ŞİFRE KARMAŞIKLIĞI KONTROLLERİ BURADA BİTER
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Şifreyi Onayla',
                    hintText: 'şifrenizi tekrar girin',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.lightTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi tekrar girin.';
                    }
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator(color: AppColors.primaryColor)
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(double.infinity, 50), // Genişliği doldur
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 18, color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Zaten bir hesabınız var mı?',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Giriş Yap!',
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}