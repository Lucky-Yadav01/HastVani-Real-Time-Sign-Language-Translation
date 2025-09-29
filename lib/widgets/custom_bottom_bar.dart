import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar implementing Accessible Learning Minimalism
/// Provides clear navigation hierarchy with haptic feedback
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BottomBarVariant variant;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            onTap(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: theme.brightness == Brightness.light
              ? Color(0xFF6B7280)
              : Color(0xFF9CA3AF),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          items: _getBottomNavItems(context),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavItems(BuildContext context) {
    switch (variant) {
      case BottomBarVariant.standard:
        return [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, Icons.home_rounded, 0),
            label: 'Home',
            tooltip: 'Home Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.play_circle_outline_rounded,
                Icons.play_circle_rounded, 1),
            label: 'Lessons',
            tooltip: 'Sign Language Lessons',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.assessment_outlined, Icons.assessment_rounded, 2),
            label: 'Practice',
            tooltip: 'Practice & Assessment',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.bluetooth_outlined, Icons.bluetooth_rounded, 3),
            label: 'Devices',
            tooltip: 'IoT Device Management',
          ),
        ];
      case BottomBarVariant.lesson:
        return [
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.skip_previous_outlined, Icons.skip_previous_rounded, 0),
            label: 'Previous',
            tooltip: 'Previous Lesson',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.pause_outlined, Icons.play_arrow_rounded, 1),
            label: 'Play',
            tooltip: 'Play/Pause Lesson',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.skip_next_outlined, Icons.skip_next_rounded, 2),
            label: 'Next',
            tooltip: 'Next Lesson',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
                Icons.more_horiz_outlined, Icons.more_horiz_rounded, 3),
            label: 'More',
            tooltip: 'More Options',
          ),
        ];
    }
  }

  Widget _buildIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = currentIndex == index;
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        key: ValueKey(isSelected),
        size: 24,
      ),
    );
  }
}

/// Bottom bar variants for different contexts
enum BottomBarVariant {
  /// Standard navigation for main app sections
  standard,

  /// Lesson-specific controls for media playback
  lesson,
}

/// Navigation handler for bottom bar interactions
class BottomBarNavigator {
  static void handleNavigation(
      BuildContext context, int index, BottomBarVariant variant) {
    switch (variant) {
      case BottomBarVariant.standard:
        _handleStandardNavigation(context, index);
        break;
      case BottomBarVariant.lesson:
        _handleLessonNavigation(context, index);
        break;
    }
  }

  static void _handleStandardNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home-dashboard',
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamed(context, '/lesson-player');
        break;
      case 2:
        Navigator.pushNamed(context, '/assessment-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/bluetooth-pairing-wizard');
        break;
    }
  }

  static void _handleLessonNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Handle previous lesson
        break;
      case 1:
        // Handle play/pause
        break;
      case 2:
        // Handle next lesson
        break;
      case 3:
        // Show more options
        _showLessonOptions(context);
        break;
    }
  }

  static void _showLessonOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.speed_outlined),
                title: Text('Playback Speed'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle playback speed
                },
              ),
              ListTile(
                leading: Icon(Icons.subtitles_outlined),
                title: Text('Captions'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle captions
                },
              ),
              ListTile(
                leading: Icon(Icons.bookmark_outline_rounded),
                title: Text('Bookmark'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle bookmark
                },
              ),
              ListTile(
                leading: Icon(Icons.share_outlined),
                title: Text('Share Progress'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle share
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Predefined bottom bars for common use cases
class BottomBars {
  BottomBars._();

  /// Standard bottom navigation for main app
  static Widget standard({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return Builder(
      builder: (context) => CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          BottomBarNavigator.handleNavigation(
              context, index, BottomBarVariant.standard);
        },
        variant: BottomBarVariant.standard,
      ),
    );
  }

  /// Lesson player controls
  static Widget lesson({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return Builder(
      builder: (context) => CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          BottomBarNavigator.handleNavigation(
              context, index, BottomBarVariant.lesson);
        },
        variant: BottomBarVariant.lesson,
        showLabels: false,
      ),
    );
  }
}
