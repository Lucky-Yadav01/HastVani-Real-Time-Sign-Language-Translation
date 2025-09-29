import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PracticeRoomsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activeRooms;
  final Function(Map<String, dynamic>) onJoinRoom;

  const PracticeRoomsWidget({
    super.key,
    required this.activeRooms,
    required this.onJoinRoom,
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
                iconName: 'group_work',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Practice Rooms',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: activeRooms.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              return _buildRoomCard(activeRooms[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final participantRatio = room['participants'] / room['maxParticipants'];

    return Container(
      width: 70.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Room header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(room['difficulty'])
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'group',
                  color: _getDifficultyColor(room['difficulty']),
                  size: 16,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room['name'],
                      style:
                          AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Host: ${room['host']}',
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(room['difficulty'])
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  room['difficulty'],
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getDifficultyColor(room['difficulty']),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 0.5.h),

          // Topic
          Text(
            'Topic: ${room['topic']}',
            style: AppTheme.lightTheme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Participants and join button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'people',
                          size: 12,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '${room['participants']}/${room['maxParticipants']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: participantRatio,
                      backgroundColor: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        participantRatio < 0.8
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.tertiary,
                      ),
                      minHeight: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              ElevatedButton(
                onPressed: room['isJoinable'] ? () => onJoinRoom(room) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(50, 28),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  room['isJoinable'] ? 'Join' : 'Full',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
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
