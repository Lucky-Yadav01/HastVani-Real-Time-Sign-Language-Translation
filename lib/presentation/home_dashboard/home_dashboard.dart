import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activity_feed.dart';
import './widgets/device_status_card.dart';
import './widgets/greeting_header.dart';
import './widgets/progress_snapshot.dart';
import './widgets/quick_actions_section.dart';
import './widgets/todays_lesson_card.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data
  final List<Map<String, dynamic>> _mockActivities = [
    {
      "type": "lesson_completed",
      "title": "Basic Greetings Completed",
      "description":
          "You've mastered the fundamentals of sign language greetings",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "value": "100%",
    },
    {
      "type": "accuracy_improved",
      "title": "Accuracy Improved",
      "description": "Your fingerspelling accuracy increased by 15%",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "value": "+15%",
    },
    {
      "type": "friend_achievement",
      "title": "Sarah earned Week Warrior",
      "description": "Your friend completed 7 consecutive days of learning",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "value": null,
    },
    {
      "type": "streak_milestone",
      "title": "7-Day Streak Achieved",
      "description": "Congratulations on maintaining your learning streak",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "value": "🔥",
    },
    {
      "type": "badge_earned",
      "title": "Alphabet Master Badge",
      "description": "You've successfully learned all 26 letters",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "value": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();

    // Simulate data refresh
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progress synced successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showLessonContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'bookmark_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('Bookmark Lesson'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('Share Progress'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'tune',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('Adjust Difficulty'),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'HastVani',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'bluetooth',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/bluetooth-pairing-wizard');
            },
            tooltip: 'Bluetooth Settings',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'menu_book',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/modules-overview-screen');
            },
            tooltip: 'Modules Overview',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'person_outline',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/social-hub-screen');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(
                  userName: 'Alex',
                  streakCount: 7,
                  hasNewAchievement: true,
                ),
                DeviceStatusCard(
                  isConnected: true,
                  batteryLevel: 85,
                  signalStrength: 92,
                  onConnectPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/bluetooth-pairing-wizard');
                  },
                ),
                TodaysLessonCard(
                  moduleName: 'Basic Signs',
                  lessonTitle: 'Family Members & Relationships',
                  thumbnailUrl:
                      'https://images.pexels.com/photos/8613313/pexels-photo-8613313.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  estimatedMinutes: 15,
                  progressPercentage: 65.0,
                  onContinuePressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, '/lesson-player');
                  },
                  onLongPress: () => _showLessonContextMenu(context),
                ),
                ProgressSnapshot(
                  weeklyMinutes: 180,
                  accuracyPercentage: 87.5,
                  nextMilestone: 'Complete 10 lessons to unlock Numbers module',
                  milestoneProgress: 70.0,
                ),
                QuickActionsSection(
                  onPracticeFingerspelling: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/assessment-screen');
                  },
                  onReviewYesterday: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/lesson-player');
                  },
                  onJoinPracticeRoom: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, '/social-hub-screen');
                  },
                ),
                ActivityFeed(activities: _mockActivities),
                SizedBox(height: 10.h), // Space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/lesson-player');
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          icon: CustomIconWidget(
            iconName: 'play_arrow',
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            'Start Lesson',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentBottomNavIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              setState(() => _currentBottomNavIndex = index);

              switch (index) {
                case 0:
                  // Already on home
                  break;
                case 1:
                  Navigator.pushNamed(context, '/lesson-player');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/assessment-screen');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/social-hub-screen');
                  break;
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
            unselectedItemColor: AppTheme.lightTheme.colorScheme.outline,
            selectedLabelStyle:
                AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: AppTheme.lightTheme.textTheme.bodySmall,
            items: [
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName:
                      _currentBottomNavIndex == 0 ? 'home' : 'home_outlined',
                  color: _currentBottomNavIndex == 0
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 24,
                ),
                label: 'Home',
                tooltip: 'Home Dashboard',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: _currentBottomNavIndex == 1
                      ? 'school'
                      : 'school_outlined',
                  color: _currentBottomNavIndex == 1
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 24,
                ),
                label: 'Learn',
                tooltip: 'Sign Language Lessons',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: _currentBottomNavIndex == 2
                      ? 'fitness_center'
                      : 'fitness_center_outlined',
                  color: _currentBottomNavIndex == 2
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 24,
                ),
                label: 'Practice',
                tooltip: 'Practice & Assessment',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName:
                      _currentBottomNavIndex == 3 ? 'person' : 'person_outline',
                  color: _currentBottomNavIndex == 3
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  size: 24,
                ),
                label: 'Profile',
                tooltip: 'User Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
