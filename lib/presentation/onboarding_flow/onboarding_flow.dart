import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/accessibility_preferences_widget.dart';
import './widgets/language_selection_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  String _selectedLanguage = 'ASL';
  bool _largeTextEnabled = false;
  bool _highContrastEnabled = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Interactive Sign Language Lessons',
      'description':
          'Learn sign language through structured lessons with real-time feedback from IoT sensor gloves. Master fingerspelling, numbers, and essential vocabulary.',
      'animation':
          'https://images.unsplash.com/photo-1559027615-cd4628902d4a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': Color(0xFF3B82F6),
      'textColor': Colors.white,
    },
    {
      'title': 'Real-Time Gesture Detection',
      'description':
          'Experience precise hand movement tracking with Bluetooth-enabled sensor gloves. Get instant feedback on finger positions and gesture accuracy.',
      'animation':
          'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': Color(0xFF10B981),
      'textColor': Colors.white,
    },
    {
      'title': 'Gamified Learning Progress',
      'description':
          'Earn badges, maintain learning streaks, and track your progress through achievements. Stay motivated with personalized milestones and rewards.',
      'animation':
          'https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': Color(0xFFF59E0B),
      'textColor': Colors.white,
    },
    {
      'title': 'Social Learning Community',
      'description':
          'Connect with fellow learners, join practice sessions, and participate in challenges. Learn together in a supportive community environment.',
      'animation':
          'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': Color(0xFF8B5CF6),
      'textColor': Colors.white,
    },
    {
      'title': 'Customize Your Experience',
      'description':
          'Choose your preferred sign language variant and accessibility settings to create a personalized learning journey.',
      'animation':
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'backgroundColor': Color(0xFFEF4444),
      'textColor': Colors.white,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Store onboarding completion and preferences
    Navigator.pushReplacementNamed(context, '/home-dashboard');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Page View
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: BouncingScrollPhysics(),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                if (index == _onboardingData.length - 1) {
                  return _buildCustomizationPage();
                }
                return OnboardingPageWidget(
                  title: _onboardingData[index]['title'],
                  description: _onboardingData[index]['description'],
                  animationAsset: _onboardingData[index]['animation'],
                  backgroundColor: _onboardingData[index]['backgroundColor'],
                  textColor: _onboardingData[index]['textColor'],
                );
              },
            ),

            // Skip Button
            if (_currentPage < _onboardingData.length - 1)
              Positioned(
                top: 8.h,
                right: 6.w,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      _onboardingData[_currentPage]['backgroundColor']
                          .withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicator
                      PageIndicatorWidget(
                        currentPage: _currentPage,
                        totalPages: _onboardingData.length,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: 4.h),

                      // Next/Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _onboardingData[_currentPage]
                                ['backgroundColor'],
                            elevation: 4,
                            shadowColor: Colors.black.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_currentPage <
                                  _onboardingData.length - 1) ...[
                                SizedBox(width: 2.w),
                                CustomIconWidget(
                                  iconName: 'arrow_forward_ios',
                                  color: _onboardingData[_currentPage]
                                      ['backgroundColor'],
                                  size: 4.w,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationPage() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _onboardingData[_currentPage]['backgroundColor'],
            _onboardingData[_currentPage]['backgroundColor']
                .withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'settings',
                          color: Colors.white,
                          size: 10.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _onboardingData[_currentPage]['title'],
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _onboardingData[_currentPage]['description'],
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.h),

              // Language Selection
              LanguageSelectionWidget(
                selectedLanguage: _selectedLanguage,
                onLanguageSelected: (language) {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
              ),

              SizedBox(height: 4.h),

              // Accessibility Preferences
              AccessibilityPreferencesWidget(
                largeTextEnabled: _largeTextEnabled,
                highContrastEnabled: _highContrastEnabled,
                onLargeTextChanged: (value) {
                  setState(() {
                    _largeTextEnabled = value;
                  });
                },
                onHighContrastChanged: (value) {
                  setState(() {
                    _highContrastEnabled = value;
                  });
                },
              ),

              SizedBox(height: 20.h), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
