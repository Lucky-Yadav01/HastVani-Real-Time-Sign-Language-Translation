import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController controller;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;

  const SearchFilterWidget({
    super.key,
    required this.controller,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search modules...',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        size: 20,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surface,
            ),
          ),

          SizedBox(height: 2.h),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                SizedBox(width: 2.w),
                _buildFilterChip('Beginner'),
                SizedBox(width: 2.w),
                _buildFilterChip('Intermediate'),
                SizedBox(width: 2.w),
                _buildFilterChip('Advanced'),
                SizedBox(width: 2.w),
                _buildFilterChip('Completed'),
                SizedBox(width: 2.w),
                _buildFilterChip('In Progress'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;

    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedColor: AppTheme.lightTheme.colorScheme.primary,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(label);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
