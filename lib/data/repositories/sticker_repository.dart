import 'package:flutter/material.dart';
import '../models/sticker_item.dart';

class StickerRepository {
  static final List<StickerDefinition> allStickers = [
    // 1. Bows
    const StickerDefinition(
      id: 'bow_coquette_pink',
      category: StickerCategory.bows,
      label: 'Silk Bow',
      emoji: '🎀',
      primaryColor: Color(0xFFF472B6),
    ),
    const StickerDefinition(
      id: 'bow_lavender',
      category: StickerCategory.bows,
      label: 'Lavender Bow',
      emoji: '🎀',
      primaryColor: Color(0xFFA78BFA),
    ),
    const StickerDefinition(
      id: 'bow_velvet_black',
      category: StickerCategory.bows,
      label: 'Velvet Ribbon',
      emoji: '🎀',
      primaryColor: Color(0xFF1F2937),
    ),

    // 2. Hearts
    const StickerDefinition(
      id: 'heart_sparkle',
      category: StickerCategory.hearts,
      label: 'Sparkle Heart',
      emoji: '💖',
      primaryColor: Color(0xFFEC4899),
    ),
    const StickerDefinition(
      id: 'heart_pixel',
      category: StickerCategory.hearts,
      label: 'Pixel Heart',
      emoji: '💓',
      primaryColor: Color(0xFFF43F5E),
    ),
    const StickerDefinition(
      id: 'heart_soft_white',
      category: StickerCategory.hearts,
      label: 'White Heart',
      emoji: '🤍',
      primaryColor: Color(0xFFF1F5F9),
    ),
    const StickerDefinition(
      id: 'heart_glitter',
      category: StickerCategory.hearts,
      label: 'Glitter Heart',
      emoji: '💕',
      primaryColor: Color(0xFFF472B6),
    ),

    // 3. Stars
    const StickerDefinition(
      id: 'star_y2k_sparkle',
      category: StickerCategory.stars,
      label: 'Y2K Sparkle',
      emoji: '🌟',
      primaryColor: Color(0xFFFBBF24),
    ),
    const StickerDefinition(
      id: 'star_cute_pastel',
      category: StickerCategory.stars,
      label: 'Pastel Star',
      emoji: '⭐',
      primaryColor: Color(0xFFFCD34D),
    ),
    const StickerDefinition(
      id: 'star_cyber_glow',
      category: StickerCategory.stars,
      label: 'Cyber Star',
      emoji: '💫',
      primaryColor: Color(0xFF38BDF8),
    ),

    // 4. Cherries
    const StickerDefinition(
      id: 'cherry_glossy',
      category: StickerCategory.cherries,
      label: 'Glossy Cherries',
      emoji: '🍒',
      primaryColor: Color(0xFFE11D48),
    ),
    const StickerDefinition(
      id: 'cherry_pair',
      category: StickerCategory.cherries,
      label: 'Sweet Pair',
      emoji: '🍒',
      primaryColor: Color(0xFFBE123C),
    ),

    // 5. Flowers
    const StickerDefinition(
      id: 'flower_cherry_blossom',
      category: StickerCategory.flowers,
      label: 'Cherry Blossom',
      emoji: '🌸',
      primaryColor: Color(0xFFF9A8D4),
    ),
    const StickerDefinition(
      id: 'flower_daisy',
      category: StickerCategory.flowers,
      label: 'White Daisy',
      emoji: '🌼',
      primaryColor: Color(0xFFFDE68A),
    ),
    const StickerDefinition(
      id: 'flower_rose',
      category: StickerCategory.flowers,
      label: 'Vintage Rose',
      emoji: '🌹',
      primaryColor: Color(0xFFE11D48),
    ),

    // 6. Teddy Bears
    const StickerDefinition(
      id: 'teddy_soft',
      category: StickerCategory.teddyBears,
      label: 'Honey Bear',
      emoji: '🧸',
      primaryColor: Color(0xFFD97706),
    ),
    const StickerDefinition(
      id: 'teddy_coquette',
      category: StickerCategory.teddyBears,
      label: 'Coquette Bear',
      emoji: '🧸',
      primaryColor: Color(0xFFF472B6),
    ),

    // 7. Butterflies
    const StickerDefinition(
      id: 'butterfly_lavender',
      category: StickerCategory.butterflies,
      label: 'Lilac Butterfly',
      emoji: '🦋',
      primaryColor: Color(0xFF818CF8),
    ),
    const StickerDefinition(
      id: 'butterfly_cyan',
      category: StickerCategory.butterflies,
      label: 'Y2K Butterfly',
      emoji: '🦋',
      primaryColor: Color(0xFF22D3EE),
    ),

    // 8. Sparkles
    const StickerDefinition(
      id: 'sparkle_twinkle',
      category: StickerCategory.sparkles,
      label: 'Magic Twinkle',
      emoji: '✨',
      primaryColor: Color(0xFFFACC15),
    ),
    const StickerDefinition(
      id: 'sparkle_burst',
      category: StickerCategory.sparkles,
      label: 'Glow Burst',
      emoji: '❇️',
      primaryColor: Color(0xFF38BDF8),
    ),

    // 9. Cute Doodles
    const StickerDefinition(
      id: 'doodle_wings',
      category: StickerCategory.cuteDoodles,
      label: 'Angel Wings',
      emoji: '🪽',
      primaryColor: Color(0xFFE0E7FF),
    ),
    const StickerDefinition(
      id: 'doodle_crown',
      category: StickerCategory.cuteDoodles,
      label: 'Princess Crown',
      emoji: '👑',
      primaryColor: Color(0xFFF59E0B),
    ),
    const StickerDefinition(
      id: 'doodle_cloud',
      category: StickerCategory.cuteDoodles,
      label: 'Dream Cloud',
      emoji: '☁️',
      primaryColor: Color(0xFFE2E8F0),
    ),

    // 10. Y2K Decorations
    const StickerDefinition(
      id: 'y2k_cd',
      category: StickerCategory.y2kDecorations,
      label: 'Holographic CD',
      emoji: '💿',
      primaryColor: Color(0xFF818CF8),
    ),
    const StickerDefinition(
      id: 'y2k_camera',
      category: StickerCategory.y2kDecorations,
      label: 'Retro Digicam',
      emoji: '📷',
      primaryColor: Color(0xFF94A3B8),
    ),
    const StickerDefinition(
      id: 'y2k_flip_phone',
      category: StickerCategory.y2kDecorations,
      label: 'Flip Phone',
      emoji: '📱',
      primaryColor: Color(0xFFF472B6),
    ),
  ];

  static List<StickerDefinition> getByCategory(StickerCategory category) {
    return allStickers.where((s) => s.category == category).toList();
  }

  static StickerDefinition getById(String id) {
    return allFilters.firstWhere(
      (s) => s.id == id,
      orElse: () => allStickers.first,
    );
  }

  static List<StickerDefinition> get allFilters => allStickers;
}
