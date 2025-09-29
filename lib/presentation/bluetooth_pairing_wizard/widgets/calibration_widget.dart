import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationWidget extends StatefulWidget {
  final Map<String, dynamic> connectedDevice;
  final Function(bool) onCalibrationComplete;

  const CalibrationWidget({
    super.key,
    required this.connectedDevice,
    required this.onCalibrationComplete,
  });

  @override
  State<CalibrationWidget> createState() => _CalibrationWidgetState();
}

class _CalibrationWidgetState extends State<CalibrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _gestureAnimationController;
  late Animation<double> _gestureAnimation;

  int _currentStep = 0;
  bool _isPerformingGesture = false;
  double _calibrationProgress = 0.0;

  final List<Map<String, dynamic>> _calibrationSteps = [
    {
      "title": "Open Hand",
      "description": "Spread your fingers wide and keep your hand flat",
      "icon": "pan_tool",
      "duration": 3,
      "accuracy": 0.0,
    },
    {
      "title": "Make a Fist",
      "description": "Close your hand into a tight fist",
      "icon": "back_hand",
      "duration": 3,
      "accuracy": 0.0,
    },
    {
      "title": "Point Forward",
      "description": "Point your index finger forward, other fingers closed",
      "icon": "touch_app",
      "duration": 3,
      "accuracy": 0.0,
    },
    {
      "title": "Peace Sign",
      "description": "Show peace sign with index and middle finger",
      "icon": "gesture",
      "duration": 3,
      "accuracy": 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _gestureAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _gestureAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _gestureAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _gestureAnimationController.dispose();
    super.dispose();
  }

  void _startGestureCalibration() async {
    setState(() {
      _isPerformingGesture = true;
      _calibrationSteps[_currentStep]["accuracy"] = 0.0;
    });

    _gestureAnimationController.repeat(reverse: true);

    // Simulate calibration progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(Duration(milliseconds: 60));
      if (mounted) {
        setState(() {
          _calibrationSteps[_currentStep]["accuracy"] = i / 100.0;
        });
      }
    }

    _gestureAnimationController.stop();

    setState(() {
      _isPerformingGesture = false;
    });

    // Add haptic feedback for successful gesture
    HapticFeedback.mediumImpact();

    // Auto advance to next step after a brief pause
    await Future.delayed(Duration(milliseconds: 800));
    _nextStep();
  }

  void _nextStep() {
    if (_currentStep < _calibrationSteps.length - 1) {
      setState(() {
        _currentStep++;
        _updateOverallProgress();
      });
    } else {
      // Calibration complete
      setState(() {
        _calibrationProgress = 1.0;
      });
      widget.onCalibrationComplete(true);
    }
  }

  void _updateOverallProgress() {
    double totalAccuracy = 0.0;
    for (int i = 0; i <= _currentStep; i++) {
      totalAccuracy += _calibrationSteps[i]["accuracy"] as double;
    }
    setState(() {
      _calibrationProgress = totalAccuracy / _calibrationSteps.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalibrationHeader(),
          SizedBox(height: 3.h),
          _buildProgressIndicator(),
          SizedBox(height: 4.h),
          _buildCurrentGestureCard(),
          SizedBox(height: 3.h),
          _buildActionButton(),
          SizedBox(height: 3.h),
          _buildStepsOverview(),
        ],
      ),
    );
  }

  Widget _buildCalibrationHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibrating ${widget.connectedDevice["name"]}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Follow the gestures to optimize sensor accuracy',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calibration Progress',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_calibrationProgress * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: _calibrationProgress,
          backgroundColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.lightTheme.colorScheme.secondary,
          ),
          minHeight: 1.h,
        ),
      ],
    );
  }

  Widget _buildCurrentGestureCard() {
    final currentGesture = _calibrationSteps[_currentStep];
    final accuracy = currentGesture["accuracy"] as double;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _gestureAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPerformingGesture ? _gestureAnimation.value : 1.0,
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: currentGesture["icon"] as String,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 12.w,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 3.h),
          Text(
            currentGesture["title"] as String,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          SizedBox(height: 1.h),
          Text(
            currentGesture["description"] as String,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          if (_isPerformingGesture) ...[
            SizedBox(height: 3.h),
            Column(
              children: [
                Text(
                  'Accuracy: ${(accuracy * 100).toInt()}%',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: accuracy,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_calibrationProgress >= 1.0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to completion
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
                iconName: 'check_circle',
                color: Colors.white,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Calibration Complete',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPerformingGesture ? null : _startGestureCalibration,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: _isPerformingGesture
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text('Calibrating...'),
                ],
              )
            : Text('Start Gesture'),
      ),
    );
  }

  Widget _buildStepsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calibration Steps',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _calibrationSteps.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final step = _calibrationSteps[index];
            final accuracy = step["accuracy"] as double;
            final isCompleted = accuracy >= 1.0;
            final isCurrent = index == _currentStep;

            return Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.05)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : isCurrent
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: Colors.white,
                              size: 4.w,
                            )
                          : Text(
                              '${index + 1}',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: isCurrent
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step["title"] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isCompleted || isCurrent
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme.lightTheme.colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        if (isCompleted)
                          Text(
                            'Accuracy: ${(accuracy * 100).toInt()}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
