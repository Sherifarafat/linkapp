import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Owns provider sign-in so presentation code stays independent of Firebase.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _providedAuth = auth;

  static Future<void>? _googleSignInInitialization;

  final FirebaseAuth? _providedAuth;
  FirebaseAuth get _auth => _providedAuth ?? FirebaseAuth.instance;
  bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  Future<UserCredential> signInWithGoogle() async {
    _ensureFirebaseReady();
    final google = GoogleSignIn.instance;
    await (_googleSignInInitialization ??= google.initialize());
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google did not return an ID token.');
    }
    return _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<UserCredential> signInWithApple() async {
    _ensureFirebaseReady();
    final rawNonce = _generateNonce();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final idToken = apple.identityToken;
    if (idToken == null) {
      throw const AuthException('Apple did not return an identity token.');
    }
    final credential = OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: rawNonce,
    );
    return _auth.signInWithCredential(credential);
  }

  void _ensureFirebaseReady() {
    if (!isFirebaseReady) {
      throw const AuthException(
        'Firebase is not configured yet. Add the FlutterFire project files first.',
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
