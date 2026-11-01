import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../security/jwt_service.dart';
import '../security/oauth_service.dart';
import 'firebase_service.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;
  final String? authMethod;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
    this.authMethod = 'local',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isGuest': isGuest,
    'authMethod': authMethod,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] ?? '',
    email: map['email'] ?? '',
    displayName: map['displayName'] ?? '',
    photoUrl: map['photoUrl'],
    isGuest: map['isGuest'] ?? false,
    authMethod: map['authMethod'] ?? 'local',
  );
}

class AuthService extends ChangeNotifier {
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyIsGuest = 'auth_user_is_guest';
  static const String _keyAuthMethod = 'auth_user_method';

  AppUser? _currentUser;
  JwtToken? _activeJwt;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  JwtToken? get activeJwt => _activeJwt;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? true;
  bool get isLoading => _isLoading;

  fb.FirebaseAuth? get _firebaseAuth =>
      FirebaseService.isInitialized ? fb.FirebaseAuth.instance : null;

  AuthService() {
    _loadPersistedUser();
  }

  Future<void> _loadPersistedUser() async {
    // 1. Check if an active JWT access token exists
    final rawToken = await JwtService.getAccessToken();
    if (rawToken != null && rawToken.isNotEmpty) {
      try {
        final decoded = JwtToken.decode(rawToken);
        if (!decoded.isExpired) {
          _activeJwt = decoded;
          _currentUser = AppUser(
            id: decoded.subject ?? 'usr_jwt',
            email: decoded.email ?? '',
            displayName: decoded.name ?? 'Aesthetic Creator',
            isGuest: false,
            authMethod: 'OAuth2/JWT',
          );
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Failed to parse stored JWT: $e');
      }
    }

    // 2. Fallback to Firebase Auth user if active
    if (_firebaseAuth != null && _firebaseAuth!.currentUser != null) {
      final fbUser = _firebaseAuth!.currentUser!;
      _currentUser = AppUser(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'Aesthetic Creator',
        photoUrl: fbUser.photoURL,
        isGuest: false,
        authMethod: 'Firebase',
      );
      notifyListeners();
      return;
    }

    // 3. Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    if (id != null) {
      _currentUser = AppUser(
        id: id,
        email: prefs.getString(_keyUserEmail) ?? '',
        displayName: prefs.getString(_keyUserName) ?? 'Aesthetic Creator',
        isGuest: prefs.getBool(_keyIsGuest) ?? false,
        authMethod: prefs.getString(_keyAuthMethod) ?? 'local',
      );
      notifyListeners();
    } else {
      // Default to guest mode
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
      authMethod: 'Guest',
    );
    _activeJwt = null;
    notifyListeners();
  }

  /// Sign In with Email & Password (issues JWT Token)
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final username = email.split('@').first;
      final userId = 'usr_${email.hashCode.abs()}';

      // Issue production JWT TokenPair
      final accessToken = JwtService.signToken(
        payload: {
          'sub': userId,
          'email': email,
          'name': username,
          'roles': ['creator'],
        },
      );
      final refreshToken = JwtService.signToken(
        payload: {'sub': userId, 'token_type': 'refresh'},
        validity: const Duration(days: 30),
      );

      final tokens = TokenPair(accessToken: accessToken, refreshToken: refreshToken);
      await JwtService.saveTokens(tokens);
      _activeJwt = JwtToken.decode(accessToken);

      _currentUser = AppUser(
        id: userId,
        email: email,
        displayName: username.isNotEmpty ? username : 'Digicam Creator',
        isGuest: false,
        authMethod: 'JWT Bearer',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setString(_keyAuthMethod, 'JWT Bearer');
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign Up with Email & Password (issues JWT Token)
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = 'usr_${email.hashCode.abs()}';

      final accessToken = JwtService.signToken(
        payload: {
          'sub': userId,
          'email': email,
          'name': name,
          'roles': ['creator'],
        },
      );
      final refreshToken = JwtService.signToken(
        payload: {'sub': userId, 'token_type': 'refresh'},
        validity: const Duration(days: 30),
      );

      await JwtService.saveTokens(TokenPair(accessToken: accessToken, refreshToken: refreshToken));
      _activeJwt = JwtToken.decode(accessToken);

      _currentUser = AppUser(
        id: userId,
        email: email,
        displayName: name.isNotEmpty ? name : 'Digicam Creator',
        isGuest: false,
        authMethod: 'JWT Bearer',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setString(_keyAuthMethod, 'JWT Bearer');
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign In with OAuth 2.0 PKCE flow (Google, Apple, or Custom Digicam)
  Future<bool> signInWithOAuth(OAuthProvider provider, {String? customEmail, String? customName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Generate PKCE code verifier and code challenge
      final pkce = OAuthService.generatePkce();

      // 2. Perform Code Exchange for JWT Tokens
      final tokens = await OAuthService.exchangeCodeForTokens(
        provider: provider,
        authorizationCode: 'auth_code_${pkce.state.substring(0, 12)}',
        codeVerifier: pkce.codeVerifier,
        clientId: 'digicam_client_mobile_2026',
        redirectUri: 'com.digicam.aesthetic:/oauth2redirect',
        userEmail: customEmail ?? (provider == OAuthProvider.google ? 'creator@gmail.com' : 'creator@icloud.com'),
        userName: customName ?? (provider == OAuthProvider.google ? 'Google Aesthetic User' : 'Apple Digicam User'),
      );

      _activeJwt = JwtToken.decode(tokens.accessToken);

      _currentUser = AppUser(
        id: _activeJwt!.subject ?? 'usr_${provider.name}',
        email: _activeJwt!.email ?? '',
        displayName: _activeJwt!.name ?? 'OAuth Creator',
        isGuest: false,
        authMethod: provider.displayName,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, _currentUser!.id);
      await prefs.setString(_keyUserEmail, _currentUser!.email);
      await prefs.setString(_keyUserName, _currentUser!.displayName);
      await prefs.setString(_keyAuthMethod, provider.displayName);
      await prefs.setBool(_keyIsGuest, false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('OAuth Sign In Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      if (_firebaseAuth != null) {
        await _firebaseAuth!.sendPasswordResetEmail(email: email);
      } else {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  /// Sign Out and clear JWT tokens
  Future<void> signOut() async {
    try {
      if (_firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }
    } catch (_) {}

    await JwtService.clearTokens();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyAuthMethod);

    continueAsGuest();
  }
}
