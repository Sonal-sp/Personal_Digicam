import 'package:flutter_test/flutter_test.dart';
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
    // Digicam collection includes Normal/Original + 5 presets = 6
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
}
