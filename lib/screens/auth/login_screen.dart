// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geziyorum/services/auth_service.dart'; // AuthService'i import et
import 'package:geziyorum/main.dart'; // AppColors için (veya colors.dart gibi ayrı bir dosyanız varsa oradan)
import 'package:geziyorum/screens/auth/register_screen.dart'; // RegisterScreen'e geçiş için
import 'package:geziyorum/screens/auth/forgot_password_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Font Awesome için bu satırı etkinleştirin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true; // Şifreyi gizleme/gösterme için

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // Başarılı girişten sonra otomatik olarak MainScreen'e yönlendirilir
        // çünkü main.dart'taki StreamBuilder auth durumunu dinliyor.
      } on AuthException catch (e) {
        // AuthService'ten gelen özel hata sınıfı AuthException'ın mesajını doğrudan kullanın.
        // Artık burada e.code kontrolüne veya errorMessage değişkenine gerek yok.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)), // Doğrudan AuthService'ten gelen mesajı kullanın
        );
      } catch (e) {
        // Diğer bilinmeyen hatalar
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

  // Google ile giriş fonksiyonu
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
      // Başarılı giriş sonrası yönlendirme main.dart'taki StreamBuilder tarafından otomatik yapılacak.
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Giriş Yap',
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
                Icon(Icons.lock_open, size: 80, color: AppColors.primaryColor),
                const SizedBox(height: 30),
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
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    hintText: 'şifrenizi girin',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.lightTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
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
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Şifremi unuttum?',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: AppColors.primaryColor)
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(double.infinity, 50), // Genişliği doldur
                        ),
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(fontSize: 18, color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ),

                const SizedBox(height: 20), // E-posta/Şifre butonu ile Google butonu arasına boşluk

                // Google ile Giriş Butonu
                _isLoading
                    ? const SizedBox.shrink() // Yükleniyorken butonu gizle
                    : ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Beyaz arka plan
                          foregroundColor: Colors.black87, // Koyu metin
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.grey), // Gri kenarlık
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: const Icon( // BURADA DEĞİŞİKLİK YAPILDI: Image.asset yerine Icon kullanıldı
                          FontAwesomeIcons.google, // Google ikonu
                          color: Colors.blue, // Google ikonuna uygun renk
                          size: 24.0,
                        ),
                        label: const Text(
                          'Google ile Giriş Yap',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(height: 20), // Google butonu ile sonraki eleman arasına boşluk

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hesabınız yok mu?',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Şimdi kaydolun!',
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