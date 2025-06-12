import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? repository})
      : _authRepository = repository ?? AuthRepository();

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user ?? _authRepository.currentUser;

  /// Initiates Google Sign-In process.
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      
      if (userCredential == null) {
        _error = "Google sign-in canceled or failed.";
      } else {
        _user = userCredential.user;
        debugPrint("User Signed In: ${_user?.email}");
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("AuthProvider Sign-In Error: $_error");
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _user = null;
      debugPrint("User Signed Out");
    } catch (e) {
      _error = e.toString();
      debugPrint("AuthProvider Sign-Out Error: $_error");
    } finally {
      _setLoading(false);
    }
  }

  /// Clears the current error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  /// Google Sign In logic.
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the Google Authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}