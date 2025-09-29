import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssessmentResultsWidget extends StatefulWidget {
  final Map<String, dynamic> results;
  final VoidCallback? onRetryAssessment;
  final VoidCallback? onContinue;
  final VoidCallback? onViewDetailedResults;

  const AssessmentResultsWidget({
    super.key,
    required this.results,
    this.onRetryAssessment,
    this.onContinue,
    this.onViewDetailedResults,
  });

  @override
  State<AssessmentResultsWidget> createState() =>
      _AssessmentResultsWidgetState();
}

class _AssessmentResultsWidgetState extends State<AssessmentResultsWidget>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _celebrationController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.results['overallScore'] as double? ?? 0.0) / 100.0,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 500), () {
      _scoreController.forward();
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      _celebrationController.forward();
      if (_isPassed()) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  bool _isPassed() {
    final score = widget.results['overallScore'] as double? ?? 0.0;
    final passingThreshold =
        widget.results['passingThreshold'] as double? ?? 80.0;
    return score >= passingThreshold;
  }

  Color _getScoreColor() {
    final score = widget.results['overallScore'] as double? ?? 0.0;
    if (score >= 80) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (score >= 60) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = _isPassed();
    final score = widget.results['overallScore'] as double? ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with celebration
          AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_celebrationAnimation.value * 0.1),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: isPassed ? 'celebration' : 'sentiment_neutral',
                      color: _getScoreColor(),
                      size: 15.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isPassed ? 'Congratulations!' : 'Keep Practicing!',
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        color: _getScoreColor(),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      isPassed
                          ? 'You passed the assessment!'
                          : 'You can retry to improve your score',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Score circle
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Container(
                width: 40.w,
                height: 40.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        value: _scoreAnimation.value,
                        strokeWidth: 2.w,
                        backgroundColor: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_getScoreColor()),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(_scoreAnimation.value * 100).toInt()}%',
                          style: AppTheme.lightTheme.textTheme.displayMedium
                              ?.copyWith(
                            color: _getScoreColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Overall Score',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Statistics
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Correct',
                        '${widget.results['correctAnswers'] ?? 0}',
                        AppTheme.lightTheme.colorScheme.secondary,
                        'check_circle',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Incorrect',
                        '${widget.results['incorrectAnswers'] ?? 0}',
                        AppTheme.lightTheme.colorScheme.error,
                        'cancel',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Skipped',
                        '${widget.results['skippedQuestions'] ?? 0}',
                        AppTheme.lightTheme.colorScheme.outline,
                        'skip_next',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Time Taken',
                        widget.results['timeTaken'] as String? ?? '00:00',
                        AppTheme.lightTheme.colorScheme.primary,
                        'timer',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Avg Accuracy',
                        '${widget.results['averageAccuracy'] ?? 0}%',
                        AppTheme.lightTheme.colorScheme.tertiary,
                        'trending_up',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Certificate readiness
          if (isPassed) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'verified',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certificate Ready!',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'You\'re eligible for module completion certificate',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Action buttons
          Column(
            children: [
              if (!isPassed) ...[
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      widget.onRetryAssessment?.call();
                    },
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 5.w,
                    ),
                    label: Text('Retry Assessment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: isPassed
                    ? ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onContinue?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'arrow_forward',
                          color: AppTheme.lightTheme.colorScheme.onSecondary,
                          size: 5.w,
                        ),
                        label: Text('Continue Learning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.secondary,
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.onSecondary,
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onContinue?.call();
                        },
                        icon: CustomIconWidget(
                          iconName: 'school',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                        label: Text('Review Lessons'),
                      ),
              ),
              SizedBox(height: 2.h),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onViewDetailedResults?.call();
                },
                icon: CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                label: Text('View Detailed Results'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, String icon) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 5.w,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
