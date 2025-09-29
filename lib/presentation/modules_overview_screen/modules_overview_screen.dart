import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/continue_learning_widget.dart';
import './widgets/module_card_widget.dart';
import './widgets/progress_header_widget.dart';
import './widgets/recommended_paths_widget.dart';
import './widgets/search_filter_widget.dart';

class ModulesOverviewScreen extends StatefulWidget {
  const ModulesOverviewScreen({super.key});

  @override
  State<ModulesOverviewScreen> createState() => _ModulesOverviewScreenState();
}

class _ModulesOverviewScreenState extends State<ModulesOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Learning Modules',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: _showFilterMenu,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showNotifications,
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Progress Header
            SliverToBoxAdapter(
              child: ProgressHeaderWidget(
                courseTitle: 'IoT Gesture Control',
                completionPercentage: 68,
                estimatedTimeRemaining: '2h 15m',
              ),
            ),

            // Search and Filter
            SliverToBoxAdapter(
              child: SearchFilterWidget(
                controller: _searchController,
                selectedFilter: _selectedFilter,
                onFilterChanged: _onFilterChanged,
                onSearchChanged: _onSearchChanged,
              ),
            ),

            // Continue Learning Section
            SliverToBoxAdapter(
              child: ContinueLearningWidget(
                onContinuePressed: _continueLastLesson,
              ),
            ),

            // Module Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = _getFilteredModules()[index];
                    return ModuleCardWidget(
                      title: module['title'],
                      thumbnail: module['thumbnail'],
                      lessonCount: module['lessonCount'],
                      completedLessons: module['completedLessons'],
                      difficulty: module['difficulty'],
                      isLocked: module['isLocked'],
                      prerequisites: module['prerequisites'],
                      accuracyScore: module['accuracyScore'],
                      onTap: () => _openModule(module),
                      onBookmarkTap: () => _toggleBookmark(module),
                      onLongPress: () => _showModuleOptions(module),
                    );
                  },
                  childCount: _getFilteredModules().length,
                ),
              ),
            ),

            // Recommended Learning Paths
            SliverToBoxAdapter(
              child: RecommendedPathsWidget(
                paths: _getRecommendedPaths(),
                onPathSelected: _selectLearningPath,
              ),
            ),

            // Bottom Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChallenge,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredModules() {
    final modules = [
      {
        'title': 'Basic Gestures',
        'thumbnail':
            'https://images.unsplash.com/photo-1559028012-481c04fa702d?w=400',
        'lessonCount': 12,
        'completedLessons': 8,
        'difficulty': 'Beginner',
        'isLocked': false,
        'prerequisites': <String>[],
        'accuracyScore': 85.5,
      },
      {
        'title': 'Advanced Patterns',
        'thumbnail':
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        'lessonCount': 15,
        'completedLessons': 3,
        'difficulty': 'Advanced',
        'isLocked': false,
        'prerequisites': ['Basic Gestures'],
        'accuracyScore': 72.3,
      },
      {
        'title': 'IoT Integration',
        'thumbnail':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        'lessonCount': 18,
        'completedLessons': 0,
        'difficulty': 'Intermediate',
        'isLocked': true,
        'prerequisites': ['Basic Gestures', 'Advanced Patterns'],
        'accuracyScore': 0.0,
      },
      {
        'title': 'Real-time Control',
        'thumbnail':
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        'lessonCount': 20,
        'completedLessons': 12,
        'difficulty': 'Advanced',
        'isLocked': false,
        'prerequisites': ['IoT Integration'],
        'accuracyScore': 89.7,
      },
    ];

    if (_selectedFilter == 'All') return modules;
    return modules
        .where((module) => module['difficulty'] == _selectedFilter)
        .toList();
  }

  List<Map<String, dynamic>> _getRecommendedPaths() {
    return [
      {
        'title': 'Complete Beginner Path',
        'description': 'Start from basics and build up',
        'moduleCount': 4,
        'estimatedTime': '6 weeks',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'title': 'Quick Mastery Path',
        'description': 'Fast track for experienced users',
        'moduleCount': 2,
        'estimatedTime': '2 weeks',
        'color': AppTheme.lightTheme.colorScheme.secondary,
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

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onSearchChanged(String query) {
    // Implement search functionality
  }

  void _continueLastLesson() {
    Navigator.pushNamed(context, AppRoutes.lessonPlayer);
  }

  void _openModule(Map<String, dynamic> module) {
    if (module['isLocked']) {
      _showUnlockDialog(module);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.lessonPlayer, arguments: module);
  }

  void _toggleBookmark(Map<String, dynamic> module) {
    // Implement bookmark functionality
  }

  void _showModuleOptions(Map<String, dynamic> module) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(iconName: 'share', size: 24),
              title: Text('Share Progress'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(iconName: 'notifications', size: 24),
              title: Text('Adjust Notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(iconName: 'refresh', size: 24),
              title: Text('Reset Module'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlockDialog(Map<String, dynamic> module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Module Locked'),
        content: Text(
            'Complete prerequisite modules to unlock: ${module['prerequisites'].join(', ')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectLearningPath(Map<String, dynamic> path) {
    // Implement learning path selection
  }

  void _createChallenge() {
    // Implement challenge creation
  }

  void _showFilterMenu() {
    // Implement filter menu
  }

  void _showNotifications() {
    // Implement notifications view
  }
}
