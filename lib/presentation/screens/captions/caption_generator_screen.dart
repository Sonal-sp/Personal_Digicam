import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/ai_caption_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../widgets/aesthetic_button.dart';
import '../../widgets/aesthetic_card.dart';

class CaptionGeneratorScreen extends StatefulWidget {
  const CaptionGeneratorScreen({super.key});

  @override
  State<CaptionGeneratorScreen> createState() => _CaptionGeneratorScreenState();
}

class _CaptionGeneratorScreenState extends State<CaptionGeneratorScreen> {
  CaptionTone _selectedTone = CaptionTone.cute;
  final TextEditingController _keywordController = TextEditingController();
  List<String> _captions = [];
  final Set<String> _favoriteCaptions = {};
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateCaptions();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _generateCaptions() async {
    setState(() => _isGenerating = true);
    AppHaptics.lightTap();

    final results = await AiCaptionService.generateCaptions(
      tone: _selectedTone,
      contextKeyword: _keywordController.text.trim(),
      count: 6,
    );

    setState(() {
      _captions = results;
      _isGenerating = false;
    });
  }

  void _copyToClipboard(String caption) {
    AppHaptics.success();
    Clipboard.setData(ClipboardData(text: caption));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.deepPlum,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: AppColors.blushPink, size: 18),
            SizedBox(width: 10),
            Text('Copied to clipboard! Ready to paste on IG/Pinterest ✨'),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(String caption) {
    AppHaptics.lightTap();
    setState(() {
      if (_favoriteCaptions.contains(caption)) {
        _favoriteCaptions.remove(caption);
      } else {
        _favoriteCaptions.add(caption);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepPlum, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Caption Generator ✨', style: AppTypography.headingSmall()),
      ),
      body: Column(
        children: [
          // 1. Tone Selector Bar
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CaptionTone.values.length,
              itemBuilder: (context, i) {
                final tone = CaptionTone.values[i];
                final isSelected = tone == _selectedTone;

                return GestureDetector(
                  onTap: () {
                    AppHaptics.lightTap();
                    setState(() => _selectedTone = tone);
                    _generateCaptions();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.deepPlum : AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppColors.deepPlum : AppColors.cardBorder,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.deepPlum.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        tone.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.pureWhite : AppColors.deepPlum,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Keyword input & Re-generate bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _keywordController,
                      decoration: const InputDecoration(
                        hintText: 'Keyword (e.g. coffee, sunset, beach)...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      onSubmitted: (_) => _generateCaptions(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AestheticButton(
                  onPressed: _generateCaptions,
                  label: 'Generate',
                  icon: Icons.auto_awesome_rounded,
                  backgroundColor: AppColors.deepPlum,
                  foregroundColor: AppColors.pureWhite,
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ],
            ),
          ),

          // 3. Captions Suggestions List
          Expanded(
            child: _isGenerating
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.deepPlum),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _captions.length,
                    itemBuilder: (context, i) {
                      final caption = _captions[i];
                      final isFav = _favoriteCaptions.contains(caption);

                      return AestheticCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                caption,
                                style: AppTypography.bodyLarge().copyWith(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Favorite button
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? Colors.pinkAccent : AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => _toggleFavorite(caption),
                            ),
                            // Copy button
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: AppColors.deepPlum, size: 20),
                              onPressed: () => _copyToClipboard(caption),
                              tooltip: 'Copy Caption',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
