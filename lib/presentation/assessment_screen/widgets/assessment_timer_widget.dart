import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssessmentTimerWidget extends StatefulWidget {
  final Duration totalDuration;
  final Function(Duration)? onTimeUpdate;
  final VoidCallback? onTimeExpired;
  final bool isPaused;

  const AssessmentTimerWidget({
    super.key,
    required this.totalDuration,
    this.onTimeUpdate,
    this.onTimeExpired,
    this.isPaused = false,
  });

  @override
  State<AssessmentTimerWidget> createState() => _AssessmentTimerWidgetState();
}

class _AssessmentTimerWidgetState extends State<AssessmentTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.totalDuration;

    _animationController = AnimationController(
      duration: widget.totalDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.addListener(() {
      final elapsed = widget.totalDuration * _animationController.value;
      final remaining = widget.totalDuration - elapsed;

      setState(() {
        _remainingTime = remaining;
      });

      widget.onTimeUpdate?.call(remaining);

      if (remaining.inSeconds <= 0) {
        widget.onTimeExpired?.call();
      }
    });

    if (!widget.isPaused) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AssessmentTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _animationController.stop();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    final totalSeconds = widget.totalDuration.inSeconds;
    final remainingSeconds = _remainingTime.inSeconds;
    final percentage = remainingSeconds / totalSeconds;

    if (percentage > 0.5) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (percentage > 0.2) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 1.w,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                );
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: _getTimerColor(),
                size: 4.w,
              ),
              SizedBox(height: 1.h),
              Text(
                _formatTime(_remainingTime),
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: _getTimerColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
