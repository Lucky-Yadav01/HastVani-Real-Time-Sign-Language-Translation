import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Accessible Learning Minimalism design
/// Provides contextual navigation with clean visual hierarchy
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = AppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: _getTitleFontSize(),
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? _getBackgroundColor(colorScheme),
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? _getElevation(),
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
      leading: leading ?? _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildActions(context),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 20,
      ),
      onPressed: onBackPressed ??
          () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
      tooltip: 'Back',
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: () {
            HapticFeedback.lightImpact();
            action.onPressed?.call();
          },
          tooltip: action.tooltip,
        );
      }
      return action;
    }).toList();
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case AppBarVariant.standard:
        return colorScheme.surface;
      case AppBarVariant.primary:
        return colorScheme.primary;
      case AppBarVariant.transparent:
        return Colors.transparent;
      case AppBarVariant.lesson:
        return colorScheme.surface;
    }
  }

  double _getElevation() {
    switch (variant) {
      case AppBarVariant.standard:
        return 0;
      case AppBarVariant.primary:
        return 2;
      case AppBarVariant.transparent:
        return 0;
      case AppBarVariant.lesson:
        return 1;
    }
  }

  double _getTitleFontSize() {
    switch (variant) {
      case AppBarVariant.standard:
        return 20;
      case AppBarVariant.primary:
        return 20;
      case AppBarVariant.transparent:
        return 18;
      case AppBarVariant.lesson:
        return 18;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar variants for different contexts
enum AppBarVariant {
  /// Standard app bar for main navigation
  standard,

  /// Primary colored app bar for important sections
  primary,

  /// Transparent app bar for overlay contexts
  transparent,

  /// Lesson-specific app bar with minimal distraction
  lesson,
}

/// Predefined app bars for common use cases
class AppBars {
  AppBars._();

  /// Home dashboard app bar
  static CustomAppBar home(BuildContext context) {
    return CustomAppBar(
      title: 'SignLearn',
      variant: AppBarVariant.standard,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.bluetooth_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/bluetooth-pairing-wizard');
          },
          tooltip: 'Bluetooth Settings',
        ),
        IconButton(
          icon: Icon(Icons.person_outline_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to profile or settings
          },
          tooltip: 'Profile',
        ),
      ],
    );
  }

  /// Lesson player app bar with minimal distraction
  static CustomAppBar lesson(BuildContext context, String lessonTitle) {
    return CustomAppBar(
      title: lessonTitle,
      variant: AppBarVariant.lesson,
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Show lesson help
          },
          tooltip: 'Help',
        ),
      ],
    );
  }

  /// Assessment screen app bar
  static CustomAppBar assessment(BuildContext context, String assessmentTitle) {
    return CustomAppBar(
      title: assessmentTitle,
      variant: AppBarVariant.standard,
      actions: [
        IconButton(
          icon: Icon(Icons.timer_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Show timer or progress
          },
          tooltip: 'Progress',
        ),
      ],
    );
  }

  /// Bluetooth pairing wizard app bar
  static CustomAppBar bluetoothPairing(BuildContext context) {
    return CustomAppBar(
      title: 'Device Pairing',
      variant: AppBarVariant.standard,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Refresh device scan
          },
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Onboarding flow app bar
  static CustomAppBar onboarding(BuildContext context, String stepTitle) {
    return CustomAppBar(
      title: stepTitle,
      variant: AppBarVariant.transparent,
      elevation: 0,
    );
  }
}
