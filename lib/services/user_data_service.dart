// lib/services/user_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // User tipini kullanmak için eklendi
import 'package:flutter/foundation.dart'; // ChangeNotifier ve debugPrint için

class UserDataService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcının Firestore'daki belge referansını döndüren yardımcı metot
  DocumentReference _userDocRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Kullanıcı verisini tek seferlik çeker
  // Bu metot artık doğrudan ProfileScreen tarafından kullanılmayacak,
  // yerine getOrCreateUserData veya streamUserData kullanılacak.
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      if (uid.isEmpty) {
        debugPrint('UserDataService: getUserData hatası - UID boş.');
        return null;
      }
      final docSnapshot = await _userDocRef(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('UserDataService: getUserData hatası: $e');
      return null;
    }
  }

  // Kullanıcı belgesini oluşturur (yalnızca belge henüz yoksa çağrılır)
  // Bu metot genellikle getOrCreateUserData içinden çağrılır.
  Future<void> createUserDocument({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // Firebase Auth'dan gelen displayName'i isim ve soyisim olarak ayırmaya çalış
      String firstName = '';
      String lastName = '';
      if (displayName != null && displayName.isNotEmpty) {
        final parts = displayName.split(' ');
        firstName = parts[0];
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }

      await _userDocRef(uid).set({
        'uid': uid, // UID'yi de belge içinde saklamak faydalı olabilir
        'email': email,
        'name': firstName,
        'surname': lastName,
        'photoURL': photoUrl, // Auth'tan gelen fotoğraf URL'si
        'bio': '', // Varsayılan boş biyografi alanı eklendi
        'phone': '', // Varsayılan boş telefon alanı eklendi
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Var olan alanları koruyarak veya yeni alan ekleyerek birleştirir
      debugPrint('UserDataService: Kullanıcı belgesi oluşturuldu/güncellendi: $uid');
    } catch (e) {
      debugPrint('UserDataService: createUserDocument hatası: $e');
      rethrow; // Hatayı tekrar fırlat ki çağıran yer yakalayabilsin
    }
  }

  // Kullanıcı verisini günceller
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      if (uid.isEmpty) {
        debugPrint('UserDataService: updateUserData hatası - UID boş.');
        return;
      }
      // updatedAt alanını otomatik olarak güncelle
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _userDocRef(uid).update(data);
      debugPrint('UserDataService: Kullanıcı verisi güncellendi: $uid - $data');
      notifyListeners(); // Dinleyicileri bilgilendir
    } on FirebaseException catch (e) {
      // update metodunda belge yoksa hata verir, bu durumda set ile oluşturmayı deneyebiliriz
      // Ancak genellikle update edilecek belge zaten vardır.
      if (e.code == 'not-found') {
        debugPrint('UserDataService: updateUserData hatası - Belge bulunamadı. Belge oluşturmayı deneyin.');
        await _userDocRef(uid).set(data, SetOptions(merge: true)); // Yoksa oluştur, varsa birleştir
        debugPrint('UserDataService: Belge bulunamadığı için set işlemi ile güncellendi.');
        notifyListeners();
      } else {
        debugPrint('UserDataService: updateUserData Firebase hatası: ${e.code} - ${e.message}');
        rethrow;
      }
    } catch (e) {
      debugPrint('UserDataService: updateUserData beklenmedik hata: $e');
      rethrow;
    }
  }

  // YENİ KRİTİK METOT: Kullanıcı verisini alır, yoksa Firebase Auth bilgilerini kullanarak oluşturur.
  Future<Map<String, dynamic>?> getOrCreateUserData({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      if (uid.isEmpty) {
        debugPrint('UserDataService: getOrCreateUserData hatası - UID boş.');
        return null;
      }

      DocumentSnapshot docSnapshot = await _userDocRef(uid).get();

      if (!docSnapshot.exists) {
        debugPrint('UserDataService: Belge yok, yeni kullanıcı belgesi oluşturuluyor: $uid');
        await createUserDocument(
          uid: uid,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
        );
        // Belgeyi oluşturduktan sonra tekrar çekmek en güvenli yöntem
        docSnapshot = await _userDocRef(uid).get();
        debugPrint('UserDataService: Yeni oluşturulan belge çekildi.');
      }
      return docSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('UserDataService: getOrCreateUserData hatası: $e');
      return null;
    }
  }

  // YENİ METOT: Kullanıcı verisini gerçek zamanlı dinlemek için Stream sağlar
  Stream<Map<String, dynamic>?> streamUserData(String uid) {
    if (uid.isEmpty) {
      debugPrint('UserDataService: streamUserData hatası - UID boş.');
      return Stream.value(null); // Boş bir akış döndür
    }
    return _userDocRef(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      }
      return null;
    });
  }
}