import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageSelectionWidget extends StatefulWidget {
  final Function(String) onLanguageSelected;
  final String selectedLanguage;

  const LanguageSelectionWidget({
    super.key,
    required this.onLanguageSelected,
    required this.selectedLanguage,
  });

  @override
  State<LanguageSelectionWidget> createState() =>
      _LanguageSelectionWidgetState();
}

class _LanguageSelectionWidgetState extends State<LanguageSelectionWidget> {
  final List<Map<String, dynamic>> languages = [
    {
      'code': 'ASL',
      'name': 'American Sign Language',
      'flag': 'https://flagcdn.com/w320/us.png',
      'description': 'Used in United States and Canada'
    },
    {
      'code': 'BSL',
      'name': 'British Sign Language',
      'flag': 'https://flagcdn.com/w320/gb.png',
      'description': 'Used in United Kingdom'
    },
    {
      'code': 'ISL',
      'name': 'Indian Sign Language',
      'flag': 'https://flagcdn.com/w320/in.png',
      'description': 'Used in India'
    },
    {
      'code': 'PSL',
      'name': 'Pakistani Sign Language',
      'flag': 'https://flagcdn.com/w320/pk.png',
      'description': 'Used in Pakistan'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Sign Language',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        ...languages.map((language) => _buildLanguageOption(language)),
      ],
    );
  }

  Widget _buildLanguageOption(Map<String, dynamic> language) {
    final isSelected = widget.selectedLanguage == language['code'];

    return GestureDetector(
      onTap: () => widget.onLanguageSelected(language['code']),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 12.w,
              height: 8.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: language['flag'],
                  width: 12.w,
                  height: 8.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Language Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language['code'],
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '- ${language['name']}',
                          style:
                              AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    language['description'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Selection Indicator
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 3.w,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
