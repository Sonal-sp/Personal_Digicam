import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

enum CaptionTone {
  cute,
  funny,
  sarcastic,
  pinterest,
  y2k,
  mysterious,
  confident,
  minimal,
  travelDiary,
  bestFriend,
}

extension CaptionToneExtension on CaptionTone {
  String get displayName {
    switch (this) {
      case CaptionTone.cute:
        return 'Cute 🎀';
      case CaptionTone.funny:
        return 'Funny 🤪';
      case CaptionTone.sarcastic:
        return 'Sarcastic 💅';
      case CaptionTone.pinterest:
        return 'Pinterest ☕';
      case CaptionTone.y2k:
        return 'Y2K 💿';
      case CaptionTone.mysterious:
        return 'Mysterious 🌙';
      case CaptionTone.confident:
        return 'Confident 👑';
      case CaptionTone.minimal:
        return 'Minimal 🕊️';
      case CaptionTone.travelDiary:
        return 'Travel Diary ✈️';
      case CaptionTone.bestFriend:
        return 'Besties 👯‍♀️';
    }
  }
}

class AiCaptionService {
  // Optional secure backend endpoint (if configured by user/server)
  static String? backendEndpoint;

  /// Generate contextual aesthetic captions based on selected tone
  static Future<List<String>> generateCaptions({
    required CaptionTone tone,
    String contextKeyword = '',
    int count = 5,
  }) async {
    // If a secure backend proxy endpoint is configured, attempt network call
    if (backendEndpoint != null && backendEndpoint!.isNotEmpty) {
      try {
        final uri = Uri.parse(backendEndpoint!);
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'tone': tone.name,
            'keyword': contextKeyword,
            'count': count,
          }),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['captions'] is List) {
            return List<String>.from(data['captions']);
          }
        }
      } catch (e) {
        // Graceful fallback to offline curated aesthetic engine
      }
    }

    // High quality offline fallback generator
    return _generateOfflineCaptions(tone, count: count);
  }

  static List<String> _generateOfflineCaptions(CaptionTone tone, {int count = 5}) {
    final pool = _toneCaptionDatabase[tone] ?? _toneCaptionDatabase[CaptionTone.cute]!;
    final shuffled = List<String>.from(pool)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  static final Map<CaptionTone, List<String>> _toneCaptionDatabase = {
    CaptionTone.cute: [
      'soft heart, loud mind & pretty moments 🎀',
      'just a girl living inside her favorite daydream 🌸',
      'cherry blossoms & sweet afternoon whispers 💕',
      'pookie aesthetic forever & ever 🩰',
      'made of stardust, sugar & vintage ribbons 🎀✨',
      'sweet like honey, gentle like morning rain 🍯',
      'wrapped in pink clouds and happy thoughts ☁️',
    ],
    CaptionTone.funny: [
      'taking 400 photos just to post one blurry one 🙃',
      'my digicam made me look cooler than I actually am 🤷‍♀️',
      'I swear I only look like this under 2000s camera flash',
      'running purely on iced coffee and emotional support filters ☕',
      'camera roll is 99% screenshots and 1% this masterpiece',
      'professional candid-photo overthinker 🤳',
    ],
    CaptionTone.sarcastic: [
      'too iconic to care, too sleepy to argue 💅',
      'sorry for being the main character in your side story ✨',
      'unbothered, moisturized, in my own lane 💅',
      'I didn’t choose the drama, the flash chose me 📸',
      'low quality camera, high quality taste 😌',
      'doing my best to look uninterested and succeeding 🕶️',
    ],
    CaptionTone.pinterest: [
      'romanticizing the quiet architecture of ordinary days 🕊️',
      'soft linen, warm morning brew & slow chapters ☕',
      'the art of living gently in a hurried world 🌿',
      'curating memories like vintage press clippings 📜',
      'golden hour pouring through sheer curtains ☀️',
      'moments that felt like poetry before they became pictures 🤍',
    ],
    CaptionTone.y2k: [
      'straight from an early 2000s cyber party 💿',
      'cyber-angel with a flash-heavy disposable ⚡',
      'y2k bug never ended, it just became our aesthetic 📱',
      'gloss on lips, digital camera on wrist 💎',
      'living like it’s 2004 and the flip phone is ringing 📟',
      'party like the millennium just started 🎆',
    ],
    CaptionTone.mysterious: [
      'shadows whisper louder than words at midnight 🌙',
      'half in the light, completely in thought 🖤',
      'not everything is meant to be decoded 🗝️',
      'seen in passing, remembered in fragments 🌫️',
      'neon reflections in quiet puddles 🌃',
    ],
    CaptionTone.confident: [
      'knowing your worth doesn’t require an explanation 👑',
      'built different, captured better ✨',
      'setting the standard, not following the trends 💅',
      'energy that can’t be replicated or duplicated ⚡',
      'glowing from the inside out, flash is just a bonus 💎',
    ],
    CaptionTone.minimal: [
      'stillness 🕊️',
      'less, but better.',
      '35mm nostalgia.',
      'just this.',
      'quiet frames.',
      'soft light.',
    ],
    CaptionTone.travelDiary: [
      'collecting passport stamps and vintage digicam shots ✈️',
      'lost in cobblestone streets and gelato dreams 🍦',
      'every sunset looks different from another hemisphere 🌅',
      'suitcases, departures, and unforgettable horizons 🗺️',
      'places that permanently borrowed a piece of my heart 🌍',
    ],
    CaptionTone.bestFriend: [
      'matching outfits, chaotic energy & forever laughs 👯‍♀️',
      'the partner in every single bad idea and good photo 💖',
      'soul sisters captured on vintage memory cards 💌',
      'who allowed us to be this iconic together? 🍒',
      'years change, but our photo dumps remain unmatched 🌸',
    ],
  };
}
