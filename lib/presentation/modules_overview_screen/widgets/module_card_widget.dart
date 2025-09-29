import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ModuleCardWidget extends StatelessWidget {
  final String title;
  final String thumbnail;
  final int lessonCount;
  final int completedLessons;
  final String difficulty;
  final bool isLocked;
  final List<String> prerequisites;
  final double accuracyScore;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onLongPress;

  const ModuleCardWidget({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.lessonCount,
    required this.completedLessons,
    required this.difficulty,
    required this.isLocked,
    required this.prerequisites,
    required this.accuracyScore,
    required this.onTap,
    required this.onBookmarkTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = lessonCount > 0 ? completedLessons / lessonCount : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with overlay
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: CustomIconWidget(
                                iconName: 'image',
                                size: 32,
                                color: Colors.grey[500],
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: CustomIconWidget(
                                iconName: 'broken_image',
                                size: 32,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                        // Lock overlay
                        if (isLocked)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(
                                  iconName: 'lock',
                                  size: 24,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        // Difficulty badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _getDifficultyColor().withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              difficulty,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4),

                        // Lesson count
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'book',
                              size: 12,
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '$completedLessons/$lessonCount',
                                style: AppTheme.lightTheme.textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        // Progress bar
                        if (!isLocked) ...[
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme
                                .lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getDifficultyColor(),
                            ),
                            minHeight: 3,
                          ),

                          SizedBox(height: 2),

                          // Accuracy score
                          if (completedLessons > 0)
                            Text(
                              '${accuracyScore.toStringAsFixed(0)}%',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bookmark button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onBookmarkTap,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'bookmark_border',
                    size: 18,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'intermediate':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'advanced':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
