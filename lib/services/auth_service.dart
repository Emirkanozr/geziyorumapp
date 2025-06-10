// lib/services/auth_service.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication paketi
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore (kullanıcı verileri için)
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In paketi import edildi

// Kimlik doğrulama hataları için özel istisna sınıfı
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {this.code = 'unknown'});

  @override
  String toString() {
    return 'AuthException: [Code: $code] $message';
  }
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn instance oluşturuldu

  // Kullanıcı durumu değişikliklerini dinlemek için Stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ----------------------------------------------------
  // E-posta ve Şifre ile Giriş Yapma
  // ----------------------------------------------------
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Başarılı giriş sonrası kullanıcıyı bildirmek için notifyListeners
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMessage = 'Yanlış şifre. Lütfen tekrar deneyin.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta formatı.';
          break;
        case 'user-disabled':
          errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmıştır.';
          break;
        case 'network-request-failed':
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        default:
          errorMessage = 'Giriş yapılırken bir hata oluştu: ${e.message}';
          break;
      }
      throw AuthException(errorMessage, code: e.code);
    } catch (e) {
      throw AuthException('Giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  // ----------------------------------------------------
  // E-posta ve Şifre ile Yeni Kullanıcı Oluşturma (Kayıt Olma)
  // ----------------------------------------------------
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String surname,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı oluşturulduktan sonra Firestore'a temel kullanıcı bilgilerini kaydet
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
          'surname': surname,
          'createdAt': Timestamp.now(),
          'signInMethod': 'email_password', // Giriş yöntemini belirt
        });
      }

      // Başarılı kayıt sonrası kullanıcıyı bildirmek için notifyListeners
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta formatı.';
          break;
        case 'network-request-failed':
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        default:
          errorMessage = 'Kayıt olurken bir hata oluştu: ${e.message}';
          break;
      }
      throw AuthException(errorMessage, code: e.code);
    } catch (e) {
      throw AuthException('Kayıt olurken beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  // ----------------------------------------------------
  // Google ile Giriş Yapma
  // ----------------------------------------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Giriş Akışını Başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı Google girişini iptal etti veya bir hata oluştu
        return null;
      }

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase Kimlik Bilgilerini Oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile oturum aç
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Kullanıcı ilk defa Google ile giriş yapıyorsa Firestore'a kaydet
      if (userCredential.user != null && userCredential.additionalUserInfo!.isNewUser) {
        // Ad ve Soyadı güvenli bir şekilde alalım
        String? displayName = googleUser.displayName;
        String firstName = '';
        String lastName = '';

        if (displayName != null && displayName.isNotEmpty) {
          List<String> nameParts = displayName.split(' ');
          firstName = nameParts.first; // Her zaman ilk kelimeyi ad olarak al
          if (nameParts.length > 1) {
            // Eğer birden fazla kelime varsa, geri kalanını soyad olarak birleştir
            lastName = nameParts.sublist(1).join(' ');
          }
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': firstName,
          'surname': lastName,
          'profilePicture': googleUser.photoUrl,
          'createdAt': Timestamp.now(),
          'signInMethod': 'google', // Giriş yöntemini belirt
        });
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Bu e-posta adresi başka bir kimlik bilgisiyle zaten kayıtlı. Lütfen mevcut yönteminizi kullanın.';
          break;
        case 'invalid-credential':
          errorMessage = 'Google kimlik bilgileri geçersiz.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google ile giriş bu proje için etkinleştirilmedi.';
          break;
        case 'network-request-failed':
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        default:
          errorMessage = 'Google ile giriş yapılırken bir hata oluştu: ${e.message}';
          break;
      }
      throw AuthException(errorMessage, code: e.code);
    } catch (e) {
      // google_sign_in paketi üzerinden gelen hatalar (örn. kullanıcı iptali)
      // MissingPluginException'ı özellikle kontrol edebiliriz
      if (e.toString().contains('MissingPluginException')) {
         throw AuthException('Google Sign-in için platform ayarları eksik veya hatalı.');
      }
      throw AuthException('Google ile giriş yapılırken beklenmedik bir hata oluştu: ${e.toString()}');
    }
  }

  // ----------------------------------------------------
  // Çıkış Yapma (Google çıkışını da ekleyelim)
  // ----------------------------------------------------
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Google hesabı ile giriş yapıldıysa, Google oturumunu da kapat
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      notifyListeners();
    } catch (e) {
      throw AuthException('Çıkış yapılırken bir hata oluştu: ${e.toString()}');
    }
  }
}