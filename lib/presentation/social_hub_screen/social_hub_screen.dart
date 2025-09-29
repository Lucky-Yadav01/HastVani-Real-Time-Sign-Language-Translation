import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievements_showcase_widget.dart';
import './widgets/challenges_section_widget.dart';
import './widgets/friend_activity_widget.dart';
import './widgets/leaderboard_widget.dart';
import './widgets/practice_rooms_widget.dart';
import './widgets/user_rank_header_widget.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String _selectedPeriod = 'Weekly';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Social Hub',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: _searchFriends,
            icon: CustomIconWidget(
              iconName: 'person_search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showPrivacySettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(iconName: 'leaderboard', size: 20),
              text: 'Rankings',
            ),
            Tab(
              icon: CustomIconWidget(iconName: 'emoji_events', size: 20),
              text: 'Challenges',
            ),
            Tab(
              icon: CustomIconWidget(iconName: 'people', size: 20),
              text: 'Friends',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // User rank header
            UserRankHeaderWidget(
              userRank: 12,
              weeklyRank: 8,
              monthlyRank: 15,
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRankingsTab(),
                  _buildChallengesTab(),
                  _buildFriendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createChallenge,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Create Challenge',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRankingsTab() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: LeaderboardWidget(
            period: _selectedPeriod,
            leaderboardData: _getLeaderboardData(),
          ),
        ),
        SliverToBoxAdapter(
          child: AchievementsShowcaseWidget(
            achievements: _getRecentAchievements(),
            onAchievementTap: _viewAchievement,
            onShareAchievement: _shareAchievement,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 2.h),
        ),
      ],
    );
  }

  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: ChallengesSectionWidget(
        dailyChallenges: _getDailyChallenges(),
        weeklyChallenges: _getWeeklyChallenges(),
        onChallengeJoin: _joinChallenge,
        onChallengeShare: _shareChallenge,
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        // Practice rooms
        PracticeRoomsWidget(
          activeRooms: _getActiveRooms(),
          onJoinRoom: _joinPracticeRoom,
        ),

        // Friend activity feed
        Expanded(
          child: FriendActivityWidget(
            activities: _getFriendActivities(),
            onLikeActivity: _likeActivity,
            onCommentActivity: _commentOnActivity,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getLeaderboardData() {
    return [
      {
        'rank': 1,
        'name': 'Sarah Chen',
        'avatar':
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?w=100',
        'score': 2847,
        'streak': 21,
        'isFriend': true,
      },
      {
        'rank': 2,
        'name': 'Alex Rodriguez',
        'avatar':
            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?w=100',
        'score': 2756,
        'streak': 18,
        'isFriend': false,
      },
      {
        'rank': 3,
        'name': 'Emma Watson',
        'avatar':
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?w=100',
        'score': 2689,
        'streak': 15,
        'isFriend': true,
      },
      {
        'rank': 12,
        'name': 'You',
        'avatar':
            'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?w=100',
        'score': 2234,
        'streak': 7,
        'isFriend': false,
        'isCurrentUser': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getRecentAchievements() {
    return [
      {
        'title': 'Perfect Week',
        'description': 'Sarah completed all lessons with 100% accuracy',
        'icon': 'star',
        'color': AppTheme.lightTheme.colorScheme.tertiary,
        'userName': 'Sarah Chen',
        'userAvatar':
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?w=100',
        'timeAgo': '2 hours ago',
      },
      {
        'title': 'Speed Master',
        'description': 'Alex completed 50 gestures in under 30 seconds',
        'icon': 'speed',
        'color': AppTheme.lightTheme.colorScheme.secondary,
        'userName': 'Alex Rodriguez',
        'userAvatar':
            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?w=100',
        'timeAgo': '5 hours ago',
      },
    ];
  }

  List<Map<String, dynamic>> _getDailyChallenges() {
    return [
      {
        'title': 'Gesture Marathon',
        'description': 'Complete 100 gestures today',
        'progress': 67,
        'total': 100,
        'reward': '500 XP',
        'participants': 234,
        'timeLeft': '8h 23m',
        'difficulty': 'Medium',
      },
      {
        'title': 'Accuracy Master',
        'description': 'Achieve 95% accuracy in any module',
        'progress': 92,
        'total': 95,
        'reward': '300 XP',
        'participants': 156,
        'timeLeft': '8h 23m',
        'difficulty': 'Hard',
      },
    ];
  }

  List<Map<String, dynamic>> _getWeeklyChallenges() {
    return [
      {
        'title': 'Learning Streak',
        'description': 'Practice every day this week',
        'progress': 5,
        'total': 7,
        'reward': '1000 XP + Badge',
        'participants': 89,
        'timeLeft': '2d 15h',
        'difficulty': 'Easy',
      },
    ];
  }

  List<Map<String, dynamic>> _getActiveRooms() {
    return [
      {
        'name': 'Beginners Practice',
        'difficulty': 'Beginner',
        'participants': 8,
        'maxParticipants': 12,
        'host': 'Sarah Chen',
        'topic': 'Basic Gestures',
        'isJoinable': true,
      },
      {
        'name': 'Advanced Techniques',
        'difficulty': 'Advanced',
        'participants': 6,
        'maxParticipants': 8,
        'host': 'Alex Rodriguez',
        'topic': 'Complex Patterns',
        'isJoinable': true,
      },
    ];
  }

  List<Map<String, dynamic>> _getFriendActivities() {
    return [
      {
        'type': 'completion',
        'userName': 'Emma Watson',
        'userAvatar':
            'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?w=100',
        'activity': 'completed "Advanced Patterns" module',
        'timeAgo': '2 hours ago',
        'likes': 12,
        'comments': 3,
        'isLiked': false,
      },
      {
        'type': 'achievement',
        'userName': 'Sarah Chen',
        'userAvatar':
            'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?w=100',
        'activity': 'earned "Perfect Week" badge',
        'timeAgo': '4 hours ago',
        'likes': 25,
        'comments': 8,
        'isLiked': true,
      },
    ];
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _searchFriends() {
    // Implement friend search
  }

  void _showPrivacySettings() {
    // Implement privacy settings
  }

  void _createChallenge() {
    // Implement challenge creation
  }

  void _viewAchievement(Map<String, dynamic> achievement) {
    // Implement achievement viewing
  }

  void _shareAchievement(Map<String, dynamic> achievement) {
    // Implement achievement sharing
  }

  void _joinChallenge(Map<String, dynamic> challenge) {
    // Implement challenge joining
  }

  void _shareChallenge(Map<String, dynamic> challenge) {
    // Implement challenge sharing
  }

  void _joinPracticeRoom(Map<String, dynamic> room) {
    // Implement practice room joining
  }

  void _likeActivity(Map<String, dynamic> activity) {
    // Implement activity liking
  }

  void _commentOnActivity(Map<String, dynamic> activity) {
    // Implement activity commenting
  }
}
