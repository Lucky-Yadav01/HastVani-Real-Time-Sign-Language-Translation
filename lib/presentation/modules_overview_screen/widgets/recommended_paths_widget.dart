import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendedPathsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> paths;
  final Function(Map<String, dynamic>) onPathSelected;

  const RecommendedPathsWidget({
    super.key,
    required this.paths,
    required this.onPathSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'route',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recommended Learning Paths',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final path = paths[index];
              return _buildPathCard(path);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPathCard(Map<String, dynamic> path) {
    return GestureDetector(
      onTap: () => onPathSelected(path),
      child: Container(
        width: 70.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              path['color'] as Color,
              (path['color'] as Color).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (path['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'trending_up',
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Spacer(),
                CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              path['title'],
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              path['description'],
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                _buildPathStat(
                  icon: 'book',
                  value: '${path['moduleCount']} modules',
                ),
                SizedBox(width: 4.w),
                _buildPathStat(
                  icon: 'schedule',
                  value: path['estimatedTime'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathStat({
    required String icon,
    required String value,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
