import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SetupCompletionWidget extends StatefulWidget {
  final Map<String, dynamic> connectedDevice;
  final double calibrationAccuracy;
  final VoidCallback onTestConnection;
  final VoidCallback onComplete;
  final VoidCallback onSkipToMockMode;

  const SetupCompletionWidget({
    super.key,
    required this.connectedDevice,
    required this.calibrationAccuracy,
    required this.onTestConnection,
    required this.onComplete,
    required this.onSkipToMockMode,
  });

  @override
  State<SetupCompletionWidget> createState() => _SetupCompletionWidgetState();
}

class _SetupCompletionWidgetState extends State<SetupCompletionWidget>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isTestingConnection = false;
  bool _testCompleted = false;
  bool _testSuccessful = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));

    // Start celebration animation
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _testCompleted = false;
    });

    // Simulate connection test
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isTestingConnection = false;
      _testCompleted = true;
      _testSuccessful = true;
    });

    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCelebrationHeader(),
          SizedBox(height: 4.h),
          _buildConnectionSummary(),
          SizedBox(height: 3.h),
          _buildTestConnectionSection(),
          SizedBox(height: 3.h),
          _buildDataSyncPreferences(),
          SizedBox(height: 4.h),
          _buildActionButtons(),
          SizedBox(height: 2.h),
          _buildSkipOption(),
        ],
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Transform.rotate(
                  angle: _rotationAnimation.value * 0.1,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'celebration',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 12.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Setup Complete!',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your HastVani glove is ready for sign language learning',
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'bluetooth_connected',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Connection Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSummaryRow(
              'Device Name', widget.connectedDevice["name"] as String),
          _buildSummaryRow(
              'Device Type', widget.connectedDevice["type"] as String),
          _buildSummaryRow(
              'Battery Level', '${widget.connectedDevice["batteryLevel"]}%'),
          _buildSummaryRow('Signal Strength',
              '${widget.connectedDevice["signalStrength"]}dBm'),
          _buildSummaryRow('Calibration Accuracy',
              '${(widget.calibrationAccuracy * 100).toInt()}%'),
          _buildSummaryRow('Connection Status', 'Connected & Ready'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestConnectionSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'speed',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Test Connection',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Verify your glove responds correctly to hand movements',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isTestingConnection ? null : _testConnection,
              child: _isTestingConnection
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text('Testing Connection...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: _testCompleted
                              ? (_testSuccessful ? 'check_circle' : 'error')
                              : 'play_arrow',
                          color: _testCompleted
                              ? (_testSuccessful
                                  ? AppTheme.lightTheme.colorScheme.secondary
                                  : AppTheme.lightTheme.colorScheme.error)
                              : AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(_testCompleted
                            ? (_testSuccessful
                                ? 'Test Successful'
                                : 'Test Failed')
                            : 'Test Connection'),
                      ],
                    ),
            ),
          ),
          if (_testCompleted && _testSuccessful) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Gesture detection working perfectly! Your glove is ready for learning.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSyncPreferences() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'sync',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Data Sync Preferences',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSyncOption(
            'Real-time Learning Data',
            'Sync gesture accuracy and progress instantly',
            true,
          ),
          _buildSyncOption(
            'Performance Analytics',
            'Share usage data to improve learning experience',
            true,
          ),
          _buildSyncOption(
            'Device Diagnostics',
            'Send device health data for better support',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncOption(String title, String description, bool defaultValue) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: defaultValue,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              // Handle sync preference change
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'rocket_launch',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Start Learning Journey',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/home-dashboard');
            },
            child: Text('Go to Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipOption() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'developer_mode',
                color: AppTheme.lightTheme.colorScheme.outline,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'No Hardware Available?',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'You can still explore HastVani with our mock device simulator',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onSkipToMockMode();
              },
              child: Text(
                'Continue with Mock Device',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
