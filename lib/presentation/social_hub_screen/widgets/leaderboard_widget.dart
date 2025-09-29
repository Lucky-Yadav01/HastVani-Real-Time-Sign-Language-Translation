import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LeaderboardWidget extends StatelessWidget {
  final String period;
  final List<Map<String, dynamic>> leaderboardData;

  const LeaderboardWidget({
    super.key,
    required this.period,
    required this.leaderboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'leaderboard',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                '$period Leaderboard',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Top 3 podium
        Container(
          height: 25.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place
              if (leaderboardData.length > 1)
                Expanded(child: _buildPodiumCard(leaderboardData[1], 2)),

              SizedBox(width: 2.w),

              // First place
              if (leaderboardData.isNotEmpty)
                Expanded(child: _buildPodiumCard(leaderboardData[0], 1)),

              SizedBox(width: 2.w),

              // Third place
              if (leaderboardData.length > 2)
                Expanded(child: _buildPodiumCard(leaderboardData[2], 3)),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Rest of leaderboard
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount:
              leaderboardData.length > 3 ? leaderboardData.length - 3 : 0,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final data = leaderboardData[index + 3];
            return _buildLeaderboardRow(data);
          },
        ),
      ],
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> data, int position) {
    final height = position == 1 ? 20.h : (position == 2 ? 16.h : 14.h);
    final isCurrentUser = data['isCurrentUser'] ?? false;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getPodiumColors(position),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                width: 2,
              )
            : null,
      ),
      child: Container(
        padding: EdgeInsets.all(0.3.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Position badge
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getPodiumColors(position)[0],
                    fontWeight: FontWeight.w700,
                    fontSize: 6.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 0.1.h),

            // Avatar
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: data['avatar'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: CustomIconWidget(
                      iconName: 'person',
                      size: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: CustomIconWidget(
                      iconName: 'person',
                      size: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 0.1.h),

            // Name
            Text(
              data['name'],
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 6.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 0.05.h),

            // Score
            Text(
              '${data['score']}',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 7.sp,
              ),
            ),

            SizedBox(height: 0.05.h),

            // Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'local_fire_department',
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 6,
                ),
                SizedBox(width: 1),
                Text(
                  '${data['streak']}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 5.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> data) {
    final isCurrentUser = data['isCurrentUser'] ?? false;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${data['rank']}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: data['avatar'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: CustomIconWidget(
                    iconName: 'person',
                    size: 20,
                    color: Colors.grey[500],
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: CustomIconWidget(
                    iconName: 'person',
                    size: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Name and friend indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data['name'],
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser
                            ? AppTheme.lightTheme.colorScheme.primary
                            : null,
                      ),
                    ),
                    if (data['isFriend'] && !isCurrentUser) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Friend',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'local_fire_department',
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${data['streak']} day streak',
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${data['score']}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isCurrentUser
                  ? AppTheme.lightTheme.colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getPodiumColors(int position) {
    switch (position) {
      case 1:
        return [
          AppTheme.lightTheme.colorScheme.tertiary,
          AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.8),
        ];
      case 2:
        return [
          AppTheme.lightTheme.colorScheme.primary,
          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
        ];
      case 3:
        return [
          AppTheme.lightTheme.colorScheme.secondary,
          AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.8),
        ];
      default:
        return [Colors.grey, Colors.grey.withValues(alpha: 0.8)];
    }
  }
}
