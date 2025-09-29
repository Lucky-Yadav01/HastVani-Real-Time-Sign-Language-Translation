import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityFeed({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Recent Activity',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          activities.isEmpty ? _buildEmptyState() : _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'timeline',
            color: AppTheme.lightTheme.colorScheme.outline,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent activity',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start learning to see your progress here',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: activities.length > 5 ? 5 : activities.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final String type = activity['type'] as String;
    final String title = activity['title'] as String;
    final String description = activity['description'] as String;
    final DateTime timestamp = activity['timestamp'] as DateTime;
    final dynamic value = activity['value'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getActivityColor(type).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _getActivityIcon(type),
              color: _getActivityColor(type),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Row(
                   children: [
                     Expanded(
                       child: Text(
                         title,
                         style:
                             AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                           fontWeight: FontWeight.w500,
                         ),
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     if (value != null) ...[
                       Flexible(
                         child: Container(
                           padding: EdgeInsets.symmetric(
                               horizontal: 2.w, vertical: 0.5.h),
                           decoration: BoxDecoration(
                             color: _getActivityColor(type).withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(
                             value.toString(),
                             style:
                                 AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                               color: _getActivityColor(type),
                               fontWeight: FontWeight.w600,
                             ),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ),
                     ],
                   ],
                 ),
                SizedBox(height: 0.5.h),
                Flexible(
                  child: Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityIcon(String type) {
    switch (type) {
      case 'lesson_completed':
        return 'check_circle';
      case 'accuracy_improved':
        return 'trending_up';
      case 'friend_achievement':
        return 'people';
      case 'streak_milestone':
        return 'local_fire_department';
      case 'badge_earned':
        return 'emoji_events';
      default:
        return 'notifications';
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'lesson_completed':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'accuracy_improved':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'friend_achievement':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'streak_milestone':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'badge_earned':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
  