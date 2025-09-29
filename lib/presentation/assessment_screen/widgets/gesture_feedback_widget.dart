import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GestureFeedbackWidget extends StatefulWidget {
  final bool isDetecting;
  final double? accuracyScore;
  final String? feedbackMessage;
  final List<String>? improvementSuggestions;
  final bool showFeedback;

  const GestureFeedbackWidget({
    super.key,
    required this.isDetecting,
    this.accuracyScore,
    this.feedbackMessage,
    this.improvementSuggestions,
    this.showFeedback = false,
  });

  @override
  State<GestureFeedbackWidget> createState() => _GestureFeedbackWidgetState();
}

class _GestureFeedbackWidgetState extends State<GestureFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));

    if (widget.isDetecting) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GestureFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDetecting != oldWidget.isDetecting) {
      if (widget.isDetecting) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    if (widget.showFeedback != oldWidget.showFeedback) {
      if (widget.showFeedback) {
        _feedbackController.forward();
      } else {
        _feedbackController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.accuracyScore == null) {
      return AppTheme.lightTheme.colorScheme.outline;
    }

    if (widget.accuracyScore! >= 0.8) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (widget.accuracyScore! >= 0.6) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  String _getStatusIcon() {
    if (widget.isDetecting) {
      return 'sensors';
    }

    if (widget.accuracyScore == null) {
      return 'gesture';
    }

    if (widget.accuracyScore! >= 0.8) {
      return 'check_circle';
    } else if (widget.accuracyScore! >= 0.6) {
      return 'warning';
    } else {
      return 'error';
    }
  }

  String _getStatusText() {
    if (widget.isDetecting) {
      return 'Detecting gesture...';
    }

    if (widget.accuracyScore == null) {
      return 'Ready to detect';
    }

    if (widget.accuracyScore! >= 0.8) {
      return 'Excellent!';
    } else if (widget.accuracyScore! >= 0.6) {
      return 'Good, try again';
    } else {
      return 'Needs improvement';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Detection status
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isDetecting ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: _getStatusIcon(),
                        color: _getStatusColor(),
                        size: 6.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(),
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.accuracyScore != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        'Accuracy: ${(widget.accuracyScore! * 100).toInt()}%',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.accuracyScore != null)
                Container(
                  width: 15.w,
                  height: 15.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: widget.accuracyScore,
                        strokeWidth: 1.w,
                        backgroundColor: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_getStatusColor()),
                      ),
                      Text(
                        '${(widget.accuracyScore! * 100).toInt()}%',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Feedback message
          if (widget.showFeedback && widget.feedbackMessage != null) ...[
            SizedBox(height: 3.h),
            AnimatedBuilder(
              animation: _feedbackAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _feedbackAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: _getStatusColor().withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      widget.feedbackMessage!,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],

          // Improvement suggestions
          if (widget.showFeedback &&
              widget.improvementSuggestions != null &&
              widget.improvementSuggestions!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            AnimatedBuilder(
              animation: _feedbackAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _feedbackAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'lightbulb',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Tips for improvement:',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        ...widget.improvementSuggestions!.map(
                          (suggestion) => Padding(
                            padding: EdgeInsets.only(bottom: 0.5.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    suggestion,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
