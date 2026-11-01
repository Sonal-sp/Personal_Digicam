import 'package:flutter_test/flutter_test.dart';
import 'package:personal_digicam/core/security/jwt_service.dart';
import 'package:personal_digicam/core/security/oauth_service.dart';
import 'package:personal_digicam/core/services/auth_service.dart';
import 'package:personal_digicam/core/services/storage_service.dart';
import 'package:personal_digicam/data/models/filter_preset.dart';
import 'package:personal_digicam/data/repositories/filter_repository.dart';
import 'package:personal_digicam/data/repositories/mood_repository.dart';
import 'package:personal_digicam/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Aesthetic Digicam app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    final authService = AuthService();

    await tester.pumpWidget(
      AestheticDigicamApp(
        storageService: storageService,
        authService: authService,
      ),
    );

    expect(find.text('Aesthetic Digicam'), findsOneWidget);
  });

  test('Filter Repository contains all 24 presets across 5 categories', () {
    expect(FilterRepository.allFilters.length, greaterThanOrEqualTo(24));
    expect(FilterRepository.getByCategory(FilterCategory.digicam).length, 6);
    expect(FilterRepository.getByCategory(FilterCategory.coquette).length, 5);
    expect(FilterRepository.getByCategory(FilterCategory.vintage).length, 5);
    expect(FilterRepository.getByCategory(FilterCategory.night).length, 4);
    expect(FilterRepository.getByCategory(FilterCategory.pinterest).length, 4);
  });

  test('Mood-to-Photo repository contains signature moods', () {
    expect(MoodRepository.allMoods.length, 9);
    final pookie = MoodRepository.getById('pookie_pink');
    expect(pookie.title, 'Pookie Pink');
    expect(pookie.recommendedStickers.isNotEmpty, true);
    expect(pookie.recommendedCaptions.isNotEmpty, true);
  });

  test('JWT Service encodes, decodes and verifies cryptographic tokens', () {
    final token = JwtService.signToken(
      payload: {
        'sub': 'user_test_123',
        'email': 'creator@digicam.aesthetic',
        'name': 'Pookie Creator',
        'roles': ['creator', 'vip'],
      },
      validity: const Duration(hours: 2),
    );

    expect(token.split('.').length, 3);

    final decoded = JwtToken.decode(token);
    expect(decoded.subject, 'user_test_123');
    expect(decoded.email, 'creator@digicam.aesthetic');
    expect(decoded.name, 'Pookie Creator');
    expect(decoded.isExpired, false);
    expect(decoded.timeUntilExpiry.inMinutes, greaterThan(100));

    // Signature verification
    expect(JwtService.verifyToken(token), true);
    expect(JwtService.verifyToken(token, secret: 'wrong_secret'), false);
  });

  test('OAuth 2.0 Service generates RFC 7636 PKCE pairs and authorization URIs', () {
    final pkce = OAuthService.generatePkce();
    expect(pkce.codeVerifier.length, 64);
    expect(pkce.codeChallenge.isNotEmpty, true);
    expect(pkce.state.length, 32);

    final authUrl = OAuthService.buildAuthorizationUrl(
      provider: OAuthProvider.google,
      clientId: 'test_client_id_123.apps.googleusercontent.com',
      redirectUri: 'com.digicam.aesthetic:/oauth2redirect',
      pkce: pkce,
    );

    expect(authUrl.queryParameters['response_type'], 'code');
    expect(authUrl.queryParameters['code_challenge'], pkce.codeChallenge);
    expect(authUrl.queryParameters['code_challenge_method'], 'S256');
    expect(authUrl.queryParameters['state'], pkce.state);
  });
}
