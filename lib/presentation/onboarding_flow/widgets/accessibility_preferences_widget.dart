import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccessibilityPreferencesWidget extends StatefulWidget {
  final bool largeTextEnabled;
  final bool highContrastEnabled;
  final Function(bool) onLargeTextChanged;
  final Function(bool) onHighContrastChanged;

  const AccessibilityPreferencesWidget({
    super.key,
    required this.largeTextEnabled,
    required this.highContrastEnabled,
    required this.onLargeTextChanged,
    required this.onHighContrastChanged,
  });

  @override
  State<AccessibilityPreferencesWidget> createState() =>
      _AccessibilityPreferencesWidgetState();
}

class _AccessibilityPreferencesWidgetState
    extends State<AccessibilityPreferencesWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessibility Preferences',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Customize your learning experience for better accessibility',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 4.h),
        _buildAccessibilityOption(
          icon: 'text_fields',
          title: 'Large Text',
          description: 'Increase text size for better readability',
          value: widget.largeTextEnabled,
          onChanged: widget.onLargeTextChanged,
        ),
        SizedBox(height: 3.h),
        _buildAccessibilityOption(
          icon: 'contrast',
          title: 'High Contrast',
          description: 'Enhance color contrast for better visibility',
          value: widget.highContrastEnabled,
          onChanged: widget.onHighContrastChanged,
        ),
      ],
    );
  }

  Widget _buildAccessibilityOption({
    required String icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.lightTheme.primaryColor,
            inactiveThumbColor: Colors.white.withValues(alpha: 0.6),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
