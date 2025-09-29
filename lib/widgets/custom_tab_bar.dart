import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Tab Bar implementing Accessible Learning Minimalism
/// Provides gesture-based lesson navigation with clear visual feedback
class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<CustomTab> tabs;
  final TabBarVariant variant;
  final bool isScrollable;
  final Function(int)? onTap;
  final EdgeInsetsGeometry? padding;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.variant = TabBarVariant.standard,
    this.isScrollable = false,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colorScheme),
        border: variant == TabBarVariant.outlined
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => _buildTab(context, tab)).toList(),
        isScrollable: isScrollable,
        onTap: (index) {
          HapticFeedback.lightImpact();
          onTap?.call(index);
        },
        labelColor: _getLabelColor(colorScheme),
        unselectedLabelColor: _getUnselectedLabelColor(colorScheme),
        labelStyle: GoogleFonts.inter(
          fontSize: _getLabelFontSize(),
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: _getLabelFontSize(),
          fontWeight: FontWeight.w400,
        ),
        indicator: _buildIndicator(colorScheme),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
        labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildTab(BuildContext context, CustomTab tab) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tab.icon != null) ...[
            Icon(tab.icon, size: 20),
            if (tab.text.isNotEmpty) SizedBox(width: 8),
          ],
          if (tab.text.isNotEmpty)
            Text(
              tab.text,
              overflow: TextOverflow.ellipsis,
            ),
          if (tab.badge != null) ...[
            SizedBox(width: 8),
            tab.badge!,
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.standard:
        return colorScheme.surface;
      case TabBarVariant.primary:
        return colorScheme.primary;
      case TabBarVariant.outlined:
        return colorScheme.surface;
      case TabBarVariant.lesson:
        return colorScheme.surface.withAlpha(242);
    }
  }

  Color _getLabelColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.standard:
        return colorScheme.primary;
      case TabBarVariant.primary:
        return colorScheme.onPrimary;
      case TabBarVariant.outlined:
        return colorScheme.primary;
      case TabBarVariant.lesson:
        return colorScheme.primary;
    }
  }

  Color _getUnselectedLabelColor(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.standard:
        return colorScheme.onSurface.withAlpha(153);
      case TabBarVariant.primary:
        return colorScheme.onPrimary.withAlpha(179);
      case TabBarVariant.outlined:
        return colorScheme.onSurface.withAlpha(153);
      case TabBarVariant.lesson:
        return colorScheme.onSurface.withAlpha(153);
    }
  }

  double _getLabelFontSize() {
    switch (variant) {
      case TabBarVariant.standard:
        return 14;
      case TabBarVariant.primary:
        return 14;
      case TabBarVariant.outlined:
        return 14;
      case TabBarVariant.lesson:
        return 13;
    }
  }

  Decoration _buildIndicator(ColorScheme colorScheme) {
    switch (variant) {
      case TabBarVariant.standard:
        return UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(1),
        );
      case TabBarVariant.primary:
        return UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.onPrimary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(1),
        );
      case TabBarVariant.outlined:
        return BoxDecoration(
          border: Border.all(
            color: colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        );
      case TabBarVariant.lesson:
        return BoxDecoration(
          color: colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        );
    }
  }
}

/// Custom tab data model
class CustomTab {
  final String text;
  final IconData? icon;
  final Widget? badge;
  final String? tooltip;

  const CustomTab({
    required this.text,
    this.icon,
    this.badge,
    this.tooltip,
  });
}

/// Tab bar variants for different contexts
enum TabBarVariant {
  /// Standard tab bar for general navigation
  standard,

  /// Primary colored tab bar for important sections
  primary,

  /// Outlined tab bar for subtle emphasis
  outlined,

  /// Lesson-specific tab bar with minimal distraction
  lesson,
}

/// Predefined tab bars for common use cases
class TabBars {
  TabBars._();

  /// Lesson categories tab bar
  static CustomTabBar lessonCategories(TabController controller) {
    return CustomTabBar(
      controller: controller,
      variant: TabBarVariant.standard,
      isScrollable: true,
      tabs: [
        CustomTab(
          text: 'Basics',
          icon: Icons.abc_rounded,
        ),
        CustomTab(
          text: 'Numbers',
          icon: Icons.numbers_rounded,
        ),
        CustomTab(
          text: 'Family',
          icon: Icons.family_restroom_rounded,
        ),
        CustomTab(
          text: 'Colors',
          icon: Icons.palette_rounded,
        ),
        CustomTab(
          text: 'Actions',
          icon: Icons.directions_run_rounded,
        ),
        CustomTab(
          text: 'Emotions',
          icon: Icons.sentiment_satisfied_rounded,
        ),
      ],
    );
  }

  /// Assessment types tab bar
  static CustomTabBar assessmentTypes(TabController controller) {
    return CustomTabBar(
      controller: controller,
      variant: TabBarVariant.outlined,
      tabs: [
        CustomTab(
          text: 'Practice',
          icon: Icons.fitness_center_rounded,
        ),
        CustomTab(
          text: 'Quiz',
          icon: Icons.quiz_rounded,
        ),
        CustomTab(
          text: 'Progress',
          icon: Icons.trending_up_rounded,
        ),
      ],
    );
  }

  /// Device connection status tab bar
  static CustomTabBar deviceStatus(TabController controller) {
    return CustomTabBar(
      controller: controller,
      variant: TabBarVariant.standard,
      tabs: [
        CustomTab(
          text: 'Available',
          icon: Icons.bluetooth_searching_rounded,
          badge: _buildBadge('3'),
        ),
        CustomTab(
          text: 'Connected',
          icon: Icons.bluetooth_connected_rounded,
          badge: _buildBadge('1'),
        ),
        CustomTab(
          text: 'History',
          icon: Icons.history_rounded,
        ),
      ],
    );
  }

  /// Lesson player controls tab bar
  static CustomTabBar lessonPlayer(TabController controller) {
    return CustomTabBar(
      controller: controller,
      variant: TabBarVariant.lesson,
      tabs: [
        CustomTab(
          text: 'Learn',
          icon: Icons.school_rounded,
        ),
        CustomTab(
          text: 'Practice',
          icon: Icons.gesture_rounded,
        ),
        CustomTab(
          text: 'Review',
          icon: Icons.rate_review_rounded,
        ),
      ],
    );
  }

  /// Onboarding steps tab bar
  static CustomTabBar onboardingSteps(TabController controller) {
    return CustomTabBar(
      controller: controller,
      variant: TabBarVariant.primary,
      tabs: [
        CustomTab(text: 'Welcome'),
        CustomTab(text: 'Setup'),
        CustomTab(text: 'Permissions'),
        CustomTab(text: 'Ready'),
      ],
    );
  }

  static Widget _buildBadge(String count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Tab bar with custom page view for gesture-based navigation
class CustomTabBarView extends StatelessWidget {
  final TabController controller;
  final List<Widget> children;
  final PageController? pageController;
  final Function(int)? onPageChanged;

  const CustomTabBarView({
    super.key,
    required this.controller,
    required this.children,
    this.pageController,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        controller.animateTo(index);
        onPageChanged?.call(index);
      },
      physics: BouncingScrollPhysics(),
      children: children,
    );
  }
}
