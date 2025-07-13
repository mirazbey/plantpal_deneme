// lib/services/auth_service.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user; // Giriş yapan kullanıcıyı tutacak değişken

  AuthService() {
    // Uygulama açıldığında kullanıcının giriş durumunu dinle
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners(); // Arayüzü güncellemek için dinleyicilere haber ver
    });
  }

  // Getter: Dışarıdan _user değişkenine erişmek için
  User? get currentUser => _user;

  // Google ile Giriş Yapma Fonksiyonu
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı giriş yapmaktan vazgeçti
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Google ile giriş hatası: $e");
      return null;
    }
  }

  // Çıkış Yapma Fonksiyonu
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}