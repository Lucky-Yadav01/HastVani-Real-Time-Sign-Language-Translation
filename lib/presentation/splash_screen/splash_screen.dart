import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start background animation
    _backgroundAnimationController.forward();

    // Delay logo animation slightly
    await Future.delayed(Duration(milliseconds: 300));
    _logoAnimationController.forward();

    // Perform initialization tasks
    await _performInitialization();

    // Navigate to appropriate screen after splash duration
    await Future.delayed(Duration(milliseconds: 2500));
    _navigateToNextScreen();
  }

  Future<void> _performInitialization() async {
    try {
      // Simulate checking JWT authentication status
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate loading user preferences
      await Future.delayed(Duration(milliseconds: 300));

      // Simulate preparing cached lesson data
      await Future.delayed(Duration(milliseconds: 400));

      // Simulate initializing BLE scanning capabilities
      await Future.delayed(Duration(milliseconds: 300));

      // Provide haptic feedback on completion
      HapticFeedback.lightImpact();
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Initialization error: $e');
    }
  }

  void _navigateToNextScreen() {
    // Mock authentication and device pairing status
    final bool isAuthenticated = _mockAuthenticationStatus();
    final bool hasDevicesPaired = _mockDevicePairingStatus();
    final bool isFirstTime = _mockFirstTimeUser();

    String nextRoute;

    if (isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else if (!isAuthenticated) {
      // For returning non-authenticated users, we'll go to onboarding
      // as login screen is not in available routes
      nextRoute = '/onboarding-flow';
    } else if (hasDevicesPaired) {
      nextRoute = '/home-dashboard';
    } else {
      nextRoute = '/bluetooth-pairing-wizard';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  bool _mockAuthenticationStatus() {
    // Mock logic: 70% chance user is authenticated
    return DateTime.now().millisecond % 10 < 7;
  }

  bool _mockDevicePairingStatus() {
    // Mock logic: 60% chance user has paired devices
    return DateTime.now().millisecond % 10 < 6;
  }

  bool _mockFirstTimeUser() {
    // Mock logic: 30% chance it's a first-time user
    return DateTime.now().millisecond % 10 < 3;
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary,
                    Color.lerp(
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.secondary,
                      _backgroundAnimation.value,
                    )!,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 2),
                    _buildLogoSection(),
                    Spacer(flex: 1),
                    _buildLoadingSection(),
                    Spacer(flex: 1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppLogo(),
                SizedBox(height: 3.h),
                _buildAppName(),
                SizedBox(height: 1.h),
                _buildTagline(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sign language gesture illustration
          CustomIconWidget(
            iconName: 'sign_language',
            size: 12.w,
            color: Colors.white,
          ),
          // Accent dot
          Positioned(
            top: 4.w,
            right: 4.w,
            child: Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      'HastVani',
      style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Learn Sign Language with IoT',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(),
        SizedBox(height: 2.h),
        _buildLoadingText(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.8),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        final loadingTexts = [
          'Initializing Bluetooth services...',
          'Loading learning modules...',
          'Preparing sign language data...',
          'Setting up IoT connections...',
        ];

        final currentIndex =
            (_backgroundAnimation.value * (loadingTexts.length - 1)).round();

        return Text(
          loadingTexts[currentIndex],
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        );
      },
    );
  }
}
