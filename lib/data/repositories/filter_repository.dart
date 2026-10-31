import '../models/filter_preset.dart';

class FilterRepository {
  static const FilterPreset original = FilterPreset(
    id: 'original',
    name: 'Normal',
    category: FilterCategory.digicam,
    description: 'Natural unfiltered camera capture',
    matrix: FilterPreset.identityMatrix,
  );

  static final List<FilterPreset> allFilters = [
    original,

    // A. DIGICAM COLLECTION
    const FilterPreset(
      id: 'y2k_flash',
      name: 'Y2K Flash',
      category: FilterCategory.digicam,
      description: 'Harsh retro flash pop with vibrant cool shadows and glowing specular highlights.',
      matrix: [
        1.25, 0.02, 0.00, 0, 20,
        0.00, 1.20, 0.02, 0, 15,
        0.02, 0.02, 1.35, 0, 30,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.05,
      defaultContrast: 1.15,
      defaultSaturation: 1.2,
      defaultVignette: 0.25,
    ),
    const FilterPreset(
      id: 'retro_ccd',
      name: 'Retro CCD',
      category: FilterCategory.digicam,
      description: 'Classic early 2000s Sony & Olympus CCD color science with punchy blues and greens.',
      matrix: [
        1.15, 0.04, -0.02, 0, 10,
        -0.02, 1.18, 0.04, 0, 12,
        0.04, -0.02, 1.28, 0, 5,
        0,    0,     0,    1, 0,
      ],
      defaultBrightness: 0.02,
      defaultContrast: 1.1,
      defaultSaturation: 1.25,
      defaultGrain: 0.15,
    ),
    const FilterPreset(
      id: 'party_2000s',
      name: '2000s Party',
      category: FilterCategory.digicam,
      description: 'Late-night disposable camera glow with high saturation and bold party energy.',
      matrix: [
        1.30, 0.05, 0.00, 0, 22,
        0.00, 1.15, 0.05, 0, 10,
        0.05, 0.00, 1.25, 0, 20,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.2,
      defaultSaturation: 1.3,
      defaultVignette: 0.35,
    ),
    const FilterPreset(
      id: 'soft_digicam',
      name: 'Soft Digicam',
      category: FilterCategory.digicam,
      description: 'Diffused early digital sensor glow with dreamy blooming highlights.',
      matrix: [
        1.08, 0.05, 0.05, 0, 15,
        0.02, 1.05, 0.02, 0, 12,
        0.05, 0.02, 1.10, 0, 18,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.08,
      defaultContrast: 0.95,
      defaultSaturation: 1.05,
    ),
    const FilterPreset(
      id: 'cool_flash',
      name: 'Cool Flash',
      category: FilterCategory.digicam,
      description: 'Icy blue flash tones popular in nostalgic cyber-aesthetic fashion portraits.',
      matrix: [
        0.95, 0.00, 0.00, 0, -5,
        0.00, 1.05, 0.05, 0, 5,
        0.05, 0.05, 1.40, 0, 32,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.15,
      defaultTemperature: -0.25,
    ),

    // B. COQUETTE COLLECTION
    const FilterPreset(
      id: 'pink_dream',
      name: 'Pink Dream',
      category: FilterCategory.coquette,
      description: 'Delicate pastel blush tone with soft romantic highlights and velvet shadows.',
      matrix: [
        1.22, 0.08, 0.08, 0, 28,
        0.02, 1.02, 0.05, 0, 12,
        0.08, 0.02, 1.16, 0, 22,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.06,
      defaultSaturation: 1.15,
    ),
    const FilterPreset(
      id: 'cherry_blush',
      name: 'Cherry Blush',
      category: FilterCategory.coquette,
      description: 'Vibrant cherry tones emphasizing rosy cheeks, soft lips, and warm romance.',
      matrix: [
        1.38, 0.00, 0.00, 0, 32,
        0.00, 1.06, 0.00, 0, 6,
        0.04, 0.00, 1.12, 0, 12,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.12,
      defaultSaturation: 1.35,
    ),
    const FilterPreset(
      id: 'soft_romance',
      name: 'Soft Romance',
      category: FilterCategory.coquette,
      description: 'Whimsical muted lavender and cream tones evoking poetic vintage letters.',
      matrix: [
        1.12, 0.06, 0.06, 0, 18,
        0.04, 1.04, 0.06, 0, 14,
        0.10, 0.06, 1.25, 0, 28,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.05,
      defaultContrast: 0.98,
    ),
    const FilterPreset(
      id: 'bow_effect',
      name: 'Bow Effect',
      category: FilterCategory.coquette,
      description: 'Glossy porcelain skin tint with pristine brightness and gentle vignette.',
      matrix: [
        1.16, 0.04, 0.04, 0, 20,
        0.02, 1.08, 0.02, 0, 15,
        0.04, 0.02, 1.14, 0, 20,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.07,
      defaultContrast: 1.05,
      defaultVignette: 0.2,
    ),
    const FilterPreset(
      id: 'angel_glow',
      name: 'Angel Glow',
      category: FilterCategory.coquette,
      description: 'Heavenly ethereal luminescence with warm pearlescent highlights.',
      matrix: [
        1.18, 0.08, 0.02, 0, 24,
        0.04, 1.14, 0.04, 0, 20,
        0.04, 0.04, 1.18, 0, 22,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.1,
      defaultContrast: 0.92,
    ),

    // C. VINTAGE COLLECTION
    const FilterPreset(
      id: 'old_film',
      name: 'Old Film',
      category: FilterCategory.vintage,
      description: 'Authentic 35mm print stock with muted greens, warm tones, and nostalgic grain.',
      matrix: [
        1.12, 0.16, 0.02, 0, 16,
        0.04, 1.02, 0.04, 0, 10,
        -0.02, 0.06, 0.82, 0, -8,
        0,     0,    0,    1, 0,
      ],
      defaultContrast: 1.1,
      defaultTemperature: 0.2,
      defaultGrain: 0.35,
    ),
    const FilterPreset(
      id: 'warm_memories',
      name: 'Warm Memories',
      category: FilterCategory.vintage,
      description: 'Golden nostalgic afternoon sunlight preserved in an old family album.',
      matrix: [
        1.20, 0.12, -0.02, 0, 22,
        0.04, 1.10, 0.00,  0, 14,
        -0.05, 0.02, 0.85, 0, -12,
        0,     0,    0,    1, 0,
      ],
      defaultContrast: 1.05,
      defaultTemperature: 0.25,
      defaultVignette: 0.2,
    ),
    const FilterPreset(
      id: 'faded_summer',
      name: 'Faded Summer',
      category: FilterCategory.vintage,
      description: 'Bleached sunshine aesthetic with lifted matte shadows and sun-bleached tones.',
      matrix: [
        1.05, 0.08, 0.02, 0, 20,
        0.02, 1.02, 0.02, 0, 18,
        0.00, 0.04, 0.92, 0, 10,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.06,
      defaultContrast: 0.88,
    ),
    const FilterPreset(
      id: 'film_grain',
      name: 'Film Grain',
      category: FilterCategory.vintage,
      description: 'High-ISO monochrome-leaning tactile texture with analog depth.',
      matrix: [
        1.05, 0.02, 0.02, 0, 8,
        0.02, 1.05, 0.02, 0, 8,
        0.02, 0.02, 1.05, 0, 8,
        0,    0,    0,    1, 0,
      ],
      defaultGrain: 0.5,
      defaultContrast: 1.15,
    ),
    const FilterPreset(
      id: 'retro_brown',
      name: 'Retro Brown',
      category: FilterCategory.vintage,
      description: 'Earthy sepia-infused tones with coffee shop warmth and cozy mood.',
      matrix: [
        1.16, 0.14, 0.00, 0, 18,
        0.06, 0.98, 0.02, 0, 8,
        -0.04, 0.04, 0.76, 0, -16,
        0,     0,    0,    1, 0,
      ],
      defaultContrast: 1.12,
      defaultTemperature: 0.3,
    ),

    // D. NIGHT COLLECTION
    const FilterPreset(
      id: 'night_flash',
      name: 'Night Flash',
      category: FilterCategory.night,
      description: 'Intense direct xenon flash cutting through inky midnight darkness.',
      matrix: [
        1.45, 0.00, 0.00, 0, 30,
        0.00, 1.40, 0.00, 0, 24,
        0.00, 0.00, 1.55, 0, 42,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.35,
      defaultVignette: 0.45,
    ),
    const FilterPreset(
      id: 'city_lights',
      name: 'City Lights',
      category: FilterCategory.night,
      description: 'Vibrant neon reflections with moody cyberpunk magenta and blue accents.',
      matrix: [
        1.25, 0.00, 0.10, 0, 15,
        0.00, 1.05, 0.05, 0, 5,
        0.10, 0.05, 1.45, 0, 35,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.25,
      defaultSaturation: 1.3,
    ),
    const FilterPreset(
      id: 'party_camera',
      name: 'Party Camera',
      category: FilterCategory.night,
      description: 'High saturated nightlife glow tuned for club lights and dancefloors.',
      matrix: [
        1.32, 0.04, 0.02, 0, 25,
        0.02, 1.22, 0.04, 0, 18,
        0.04, 0.02, 1.38, 0, 32,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.22,
      defaultSaturation: 1.4,
    ),
    const FilterPreset(
      id: 'midnight_glow',
      name: 'Midnight Glow',
      category: FilterCategory.night,
      description: 'Dark moody twilight with luminous deep blue and silver undertones.',
      matrix: [
        0.88, 0.02, 0.06, 0, -8,
        0.02, 0.95, 0.08, 0, 0,
        0.08, 0.08, 1.42, 0, 38,
        0,    0,    0,    1, 0,
      ],
      defaultContrast: 1.18,
      defaultTemperature: -0.3,
    ),

    // E. PINTEREST COLLECTION
    const FilterPreset(
      id: 'soft_beige',
      name: 'Soft Beige',
      category: FilterCategory.pinterest,
      description: 'Clean, understated aesthetic beige tones seen in modern lifestyle feeds.',
      matrix: [
        1.08, 0.05, 0.00, 0, 14,
        0.02, 1.05, 0.02, 0, 10,
        0.00, 0.02, 0.94, 0, 4,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.04,
      defaultContrast: 0.98,
      defaultTemperature: 0.12,
    ),
    const FilterPreset(
      id: 'cafe_aesthetic',
      name: 'Cafe Aesthetic',
      category: FilterCategory.pinterest,
      description: 'Warm oat milk latte tones, wooden table texture, and bakery cozy vibes.',
      matrix: [
        1.18, 0.10, 0.00, 0, 16,
        0.04, 1.08, 0.02, 0, 12,
        -0.02, 0.02, 0.88, 0, -6,
        0,     0,    0,    1, 0,
      ],
      defaultContrast: 1.08,
      defaultTemperature: 0.22,
    ),
    const FilterPreset(
      id: 'golden_hour',
      name: 'Golden Hour',
      category: FilterCategory.pinterest,
      description: 'Warm radiant sunbeams, glowing skin, and amber sunset tones.',
      matrix: [
        1.32, 0.12, -0.04, 0, 28,
        0.06, 1.20, -0.02, 0, 18,
        -0.10, 0.00, 0.80, 0, -18,
        0,     0,    0,    1, 0,
      ],
      defaultBrightness: 0.04,
      defaultContrast: 1.15,
      defaultSaturation: 1.25,
      defaultTemperature: 0.35,
    ),
    const FilterPreset(
      id: 'dreamy_light',
      name: 'Dreamy Light',
      category: FilterCategory.pinterest,
      description: 'Soft luminous aesthetic haze with pastel reflections and delicate contrast.',
      matrix: [
        1.14, 0.06, 0.04, 0, 22,
        0.04, 1.10, 0.04, 0, 18,
        0.04, 0.04, 1.16, 0, 20,
        0,    0,    0,    1, 0,
      ],
      defaultBrightness: 0.08,
      defaultContrast: 0.94,
    ),
  ];

  static List<FilterPreset> getByCategory(FilterCategory category) {
    return allFilters.where((f) => f.category == category).toList();
  }

  static FilterPreset getById(String id) {
    return allFilters.firstWhere(
      (f) => f.id == id,
      orElse: () => original,
    );
  }
}
