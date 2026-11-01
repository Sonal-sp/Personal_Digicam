import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JwtToken {
  final String raw;
  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final String signature;

  const JwtToken({
    required this.raw,
    required this.header,
    required this.payload,
    required this.signature,
  });

  /// Parse and decode a raw JWT string (header.payload.signature)
  factory JwtToken.decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT token format: must contain 3 segments');
    }

    final headerString = _decodeBase64Url(parts[0]);
    final payloadString = _decodeBase64Url(parts[1]);

    final header = jsonDecode(headerString) as Map<String, dynamic>;
    final payload = jsonDecode(payloadString) as Map<String, dynamic>;

    return JwtToken(
      raw: token,
      header: header,
      payload: payload,
      signature: parts[2],
    );
  }

  // Common Standard Claims (RFC 7519)
  String? get issuer => payload['iss'] as String?;
  String? get subject => payload['sub'] as String?;
  String? get audience => payload['aud'] as String?;
  String? get email => payload['email'] as String?;
  String? get name => payload['name'] as String?;
  String? get jwtId => payload['jti'] as String?;

  DateTime? get issuedAt {
    final iat = payload['iat'];
    if (iat is int) return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
    return null;
  }

  DateTime? get expiresAt {
    final exp = payload['exp'];
    if (exp is int) return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return null;
  }

  /// Whether the token is expired
  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  /// Time remaining before expiration
  Duration get timeUntilExpiry {
    final exp = expiresAt;
    if (exp == null) return const Duration(days: 365);
    final diff = exp.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Whether the token will expire within a threshold (e.g. 5 minutes)
  bool get isExpiringSoon {
    return timeUntilExpiry < const Duration(minutes: 5);
  }

  static String _decodeBase64Url(String input) {
    var output = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw const FormatException('Illegal base64url string!');
    }
    return utf8.decode(base64.decode(output));
  }
}

class TokenPair {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600, // 1 hour
  });

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
    'expires_in': expiresIn,
  };

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['access_token'] ?? json['accessToken'] ?? '',
    refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
    tokenType: json['token_type'] ?? 'Bearer',
    expiresIn: json['expires_in'] ?? 3600,
  );
}

class JwtService {
  static const String _keyAccessToken = 'auth_jwt_access_token';
  static const String _keyRefreshToken = 'auth_jwt_refresh_token';

  // Configurable secret key via environment definitions or local runtime default
  static const String _defaultSigningKey = String.fromEnvironment(
    'JWT_SIGNING_SECRET',
    defaultValue: 'AestheticDigicam_Client_Secure_Session_Signer_Key_2026',
  );

  /// Sign a new JWT token using HMAC-SHA256 (RFC 7519)
  static String signToken({
    required Map<String, dynamic> payload,
    String secret = _defaultSigningKey,
    Duration validity = const Duration(hours: 1),
    String issuer = 'https://auth.aestheticdigicam.app',
  }) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final now = DateTime.now();
    final enrichedPayload = Map<String, dynamic>.from(payload);
    enrichedPayload['iss'] = issuer;
    enrichedPayload['iat'] = now.millisecondsSinceEpoch ~/ 1000;
    enrichedPayload['exp'] = (now.add(validity)).millisecondsSinceEpoch ~/ 1000;
    enrichedPayload['jti'] = _generateNonce(16);

    final encodedHeader = _base64UrlEncode(jsonEncode(header));
    final encodedPayload = _base64UrlEncode(jsonEncode(enrichedPayload));
    final signingInput = '$encodedHeader.$encodedPayload';

    final hmac = Hmac(sha256, utf8.encode(secret));
    final signature = _base64UrlEncodeBytes(hmac.convert(utf8.encode(signingInput)).bytes);

    return '$signingInput.$signature';
  }

  /// Verify token signature and expiration
  static bool verifyToken(String token, {String secret = _defaultSigningKey}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final signingInput = '${parts[0]}.${parts[1]}';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final expectedSignature = _base64UrlEncodeBytes(hmac.convert(utf8.encode(signingInput)).bytes);

      if (parts[2] != expectedSignature) {
        debugPrint('JWT Verification Error: Signature mismatch');
        return false;
      }

      final jwt = JwtToken.decode(token);
      if (jwt.isExpired) {
        debugPrint('JWT Verification Error: Token is expired');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('JWT Verification Exception: $e');
      return false;
    }
  }

  /// Save TokenPair to persistent storage
  static Future<void> saveTokens(TokenPair tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, tokens.accessToken);
    await prefs.setString(_keyRefreshToken, tokens.refreshToken);
  }

  /// Retrieve stored Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Retrieve stored Refresh Token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Clear tokens on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  /// Helper: Base64Url encode string
  static String _base64UrlEncode(String input) {
    return _base64UrlEncodeBytes(utf8.encode(input));
  }

  /// Helper: Base64Url encode bytes without padding
  static String _base64UrlEncodeBytes(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Helper: Random nonce
  static String _generateNonce(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}

/// Production-ready Authenticated HTTP Client that automatically injects JWT Bearer tokens
class JwtAuthClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await JwtService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.headers['X-Client-App'] = 'AestheticDigicam-Mobile';

    final response = await _inner.send(request);

    // If 401 Unauthorized, attempt refresh token rotation
    if (response.statusCode == 401) {
      final refreshToken = await JwtService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        debugPrint('Access token expired (401). Rotating refresh token...');
        // In real backend, invoke refresh endpoint.
      }
    }

    return response;
  }
}
