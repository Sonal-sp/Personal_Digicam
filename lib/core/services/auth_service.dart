import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isGuest': isGuest,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] ?? '',
    email: map['email'] ?? '',
    displayName: map['displayName'] ?? '',
    photoUrl: map['photoUrl'],
    isGuest: map['isGuest'] ?? false,
  );
}

class AuthService extends ChangeNotifier {
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyIsGuest = 'auth_user_is_guest';

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? true;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadPersistedUser();
  }

  Future<void> _loadPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id != null) {
      _currentUser = AppUser(
        id: id,
        email: prefs.getString(_keyUserEmail) ?? '',
        displayName: prefs.getString(_keyUserName) ?? 'Aesthetic Creator',
        isGuest: prefs.getBool(_keyIsGuest) ?? false,
      );
      notifyListeners();
    } else {
      // Default to guest so camera & editor are immediately usable without barrier
      continueAsGuest();
    }
  }

  /// Guest access - explore without forced login
  Future<void> continueAsGuest() async {
    _currentUser = const AppUser(
      id: 'guest_user',
      email: 'guest@digicam.local',
      displayName: 'Guest Creator 🎀',
      isGuest: true,
    );
    notifyListeners();
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate / perform authentication
      await Future.delayed(const Duration(milliseconds: 600));
      
      final username = email.split('@').first;
      _currentUser = AppUser(
        id: 'usr_${email.hashCode.abs()}',
        email: email,
        displayName: username.isNotEmpty ? username : 'Digicam Creator',
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign Up with Email & Password
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      _currentUser = AppUser(
        id: 'usr_${email.hashCode.abs()}',
        email: email,
        displayName: name.isNotEmpty ? name : 'Digicam Creator',
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = const AppUser(
        id: 'google_user_01',
        email: 'creator@gmail.com',
        displayName: 'Google Digicam User',
        isGuest: false,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Password Reset
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Sign Out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsGuest);

    continueAsGuest();
  }
}
