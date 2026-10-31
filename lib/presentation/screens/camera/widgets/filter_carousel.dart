import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/haptic_feedback.dart';
import '../../../../data/models/filter_preset.dart';
import '../../../../data/repositories/filter_repository.dart';

class FilterCarousel extends StatefulWidget {
  final FilterPreset selectedFilter;
  final double filterIntensity;
  final ValueChanged<FilterPreset> onFilterSelected;
  final ValueChanged<double> onIntensityChanged;

  const FilterCarousel({
    super.key,
    required this.selectedFilter,
    required this.filterIntensity,
    required this.onFilterSelected,
    required this.onIntensityChanged,
  });

  @override
  State<FilterCarousel> createState() => _FilterCarouselState();
}

class _FilterCarouselState extends State<FilterCarousel> {
  FilterCategory? _activeCategory; // null = All

  @override
  Widget build(BuildContext context) {
    final filters = _activeCategory == null
        ? FilterRepository.allFilters
        : [
            FilterRepository.original,
            ...FilterRepository.getByCategory(_activeCategory!),
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Intensity Slider (only shown if not 'original')
        if (widget.selectedFilter.id != 'original')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  'INTENSITY',
                  style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.retroOrange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: widget.filterIntensity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: AppColors.retroOrange,
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      AppHaptics.dialTick();
                      widget.onIntensityChanged(val);
                    },
                  ),
                ),
                Text(
                  '${(widget.filterIntensity * 100).round()}%',
                  style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.pureWhite),
                ),
              ],
            ),
          ),

        // Category Tab Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildCategoryChip('All', null),
              ...FilterCategory.values.map(
                (cat) => _buildCategoryChip(cat.displayName, cat),
              ),
            ],
          ),
        ),

        // Horizontal Filters Carousel
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = filter.id == widget.selectedFilter.id;

              return GestureDetector(
                onTap: () {
                  AppHaptics.dialTick();
                  widget.onFilterSelected(filter);
                },
                child: Container(
                  width: 68,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blushPink.withValues(alpha: 0.3) : Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.retroOrange : Colors.white12,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Filter icon with color sample
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.retroOrange : Colors.white24,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.retroOrange.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            filter.id == 'original'
                                ? Icons.lens_blur_rounded
                                : filter.category.icon,
                            color: isSelected ? Colors.black : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.retroOrange : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, FilterCategory? cat) {
    final isSelected = _activeCategory == cat;
    return GestureDetector(
      onTap: () {
        AppHaptics.lightTap();
        setState(() {
          _activeCategory = cat;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blushPink : Colors.black54,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.deepPlum : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.deepPlum : Colors.white70,
          ),
        ),
      ),
    );
  }
}
