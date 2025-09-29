import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import './widgets/gesture_detection_overlay_widget.dart';
import './widgets/practice_controls_widget.dart';
import './widgets/progress_tracking_widget.dart';
import './widgets/telemetry_visualization_widget.dart';
import './widgets/video_instruction_widget.dart';

class LessonPlayer extends StatefulWidget {
  const LessonPlayer({super.key});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // Mock lesson data
  final List<Map<String, dynamic>> _lessonData = [
    {
      "id": 1,
      "title": "Letter A",
      "videoUrl":
          "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
      "description": "Learn how to sign the letter A in American Sign Language",
      "difficulty": "Beginner",
      "duration": "2:30",
      "category": "Alphabet",
    },
    {
      "id": 2,
      "title": "Letter B",
      "videoUrl":
          "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4",
      "description": "Learn how to sign the letter B in American Sign Language",
      "difficulty": "Beginner",
      "duration": "2:45",
      "category": "Alphabet",
    },
    {
      "id": 3,
      "title": "Letter C",
      "videoUrl":
          "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_3mb.mp4",
      "description": "Learn how to sign the letter C in American Sign Language",
      "difficulty": "Beginner",
      "duration": "3:00",
      "category": "Alphabet",
    },
  ];

  // Mock telemetry data
  final Map<String, dynamic> _mockTelemetryData = {
    "fingerPositions": {
      "thumb": 85.0,
      "index": 92.0,
      "middle": 78.0,
      "ring": 88.0,
      "pinky": 95.0,
    },
    "orientation": {
      "x": 12.5,
      "y": -8.3,
      "z": 45.7,
    },
    "accelerometer": {
      "x": 0.2,
      "y": -0.1,
      "z": 9.8,
    },
    "gyroscope": {
      "x": 0.05,
      "y": 0.02,
      "z": -0.03,
    },
    "batteryLevel": 78,
    "signalStrength": -45,
  };

  // Mock attempt history
  final List<Map<String, dynamic>> _attemptHistory = [
    {"attempt": 1, "accuracy": 45.0, "timestamp": "2025-09-27T15:05:00"},
    {"attempt": 2, "accuracy": 62.0, "timestamp": "2025-09-27T15:06:30"},
    {"attempt": 3, "accuracy": 78.0, "timestamp": "2025-09-27T15:08:15"},
    {"attempt": 4, "accuracy": 85.0, "timestamp": "2025-09-27T15:10:00"},
    {"attempt": 5, "accuracy": 92.0, "timestamp": "2025-09-27T15:11:45"},
  ];

  int _currentLessonIndex = 0;
  int _currentTabIndex = 0;
  bool _isConnected = true;
  bool _isPlaying = false;
  bool _isPracticing = false;
  double _accuracyScore = 85.0;
  int _attempts = 5;
  Duration _timeSpent = Duration(minutes: 12, seconds: 30);

  // Gesture detection data
  final Map<String, dynamic> _targetPosition = {
    "x": 150.0,
    "y": 200.0,
    "rotation": 0.0,
  };

  final Map<String, dynamic> _currentPosition = {
    "x": 180.0,
    "y": 220.0,
    "rotation": 15.0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        _pageController.animateToPage(
          _tabController.index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Lesson?',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Your progress will be saved. Are you sure you want to exit this lesson?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _onWatchAgain() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = true;
    });
    // Reset video to beginning and play
  }

  void _onTryNow() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPracticing = !_isPracticing;
      if (_isPracticing) {
        _attempts++;
      }
    });

    if (_isPracticing) {
      // Start practice session
      Future.delayed(Duration(seconds: 5), () {
        if (mounted && _isPracticing) {
          setState(() {
            _isPracticing = false;
            _accuracyScore = (60 + (30 * (DateTime.now().millisecond / 1000)))
                .clamp(60.0, 95.0);
          });
          HapticFeedback.heavyImpact();
        }
      });
    }
  }

  void _onNextSign() {
    if (_currentLessonIndex < _lessonData.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _attempts = 0;
        _accuracyScore = 0.0;
        _timeSpent = Duration.zero;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onPreviousSign() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
        _attempts = 0;
        _accuracyScore = 0.0;
        _timeSpent = Duration.zero;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = _lessonData[_currentLessonIndex];

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: _showExitConfirmation,
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLesson['title'] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            Text(
              '${_currentLessonIndex + 1} of ${_lessonData.length} • ${currentLesson['category']}',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleConnection,
            icon: CustomIconWidget(
              iconName:
                  _isConnected ? 'bluetooth_connected' : 'bluetooth_disabled',
              color: _isConnected
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.outline,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/modules-overview-screen');
            },
            icon: CustomIconWidget(
              iconName: 'menu_book',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Modules Overview',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width *
                    ((_currentLessonIndex + 1) / _lessonData.length) *
                    0.9,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'play_circle',
                        color: _currentTabIndex == 0
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Learn',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'gesture',
                        color: _currentTabIndex == 1
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Practice',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'analytics',
                        color: _currentTabIndex == 2
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Progress',
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),

          SizedBox(height: 16),

          // Tab Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
                setState(() {
                  _currentTabIndex = index;
                });
              },
              children: [
                // Learn Tab
                _buildLearnTab(currentLesson),

                // Practice Tab
                _buildPracticeTab(currentLesson),

                // Progress Tab
                _buildProgressTab(currentLesson),
              ],
            ),
          ),

          // Bottom Controls
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: PracticeControlsWidget(
                onWatchAgain: _onWatchAgain,
                onTryNow: _onTryNow,
                onNextSign: _onNextSign,
                onPreviousSign: _onPreviousSign,
                canGoNext: _currentLessonIndex < _lessonData.length - 1,
                canGoPrevious: _currentLessonIndex > 0,
                isPlaying: _isPlaying,
                isPracticing: _isPracticing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnTab(Map<String, dynamic> lesson) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Instruction
          VideoInstructionWidget(
            videoUrl: lesson['videoUrl'] as String,
            lessonTitle: lesson['title'] as String,
            onPlayPauseChanged: (isPlaying) {
              setState(() {
                _isPlaying = isPlaying;
              });
            },
          ),

          SizedBox(height: 16),

          // Lesson Description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lesson['difficulty'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      lesson['duration'] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  lesson['description'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Key Points
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Key Points',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Keep your fingers together and thumb across your palm\n'
                  '• Make sure your hand is clearly visible\n'
                  '• Practice the motion slowly before speeding up\n'
                  '• Use your IoT glove for real-time feedback',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          SizedBox(height: 100), // Bottom padding for controls
        ],
      ),
    );
  }

  Widget _buildPracticeTab(Map<String, dynamic> lesson) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry Visualization
          TelemetryVisualizationWidget(
            telemetryData: _mockTelemetryData,
            accuracyScore: _accuracyScore,
            isConnected: _isConnected,
          ),

          SizedBox(height: 16),

          // Gesture Detection Overlay
          GestureDetectionOverlayWidget(
            targetPosition: _targetPosition,
            currentPosition: _currentPosition,
            isDetecting: _isPracticing,
            onRetry: () {
              setState(() {
                _attempts++;
              });
            },
          ),

          SizedBox(height: 16),

          // Practice Tips
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'tips_and_updates',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Practice Tips',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Connect your IoT glove for the best practice experience. The real-time feedback will help you perfect your signing technique.',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          SizedBox(height: 100), // Bottom padding for controls
        ],
      ),
    );
  }

  Widget _buildProgressTab(Map<String, dynamic> lesson) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Tracking
          ProgressTrackingWidget(
            attempts: _attempts,
            accuracyPercentage: _accuracyScore,
            timeSpent: _timeSpent,
            attemptHistory: _attemptHistory,
            currentSign: lesson['title'] as String,
          ),

          SizedBox(height: 16),

          // Achievement Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'emoji_events',
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Achievements',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAchievementBadge('First Attempt', true),
                    _buildAchievementBadge(
                        '60% Accuracy', _accuracyScore >= 60),
                    _buildAchievementBadge(
                        '80% Accuracy', _accuracyScore >= 80),
                    _buildAchievementBadge(
                        'Perfect Sign', _accuracyScore >= 95),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 100), // Bottom padding for controls
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, bool achieved) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achieved
            ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achieved
              ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: achieved ? 'check_circle' : 'radio_button_unchecked',
            color: achieved
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.outline,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: achieved
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.outline,
              fontWeight: achieved ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
