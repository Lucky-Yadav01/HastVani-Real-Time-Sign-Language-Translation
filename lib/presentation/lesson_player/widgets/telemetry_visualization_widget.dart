import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class TelemetryVisualizationWidget extends StatefulWidget {
  final Map<String, dynamic> telemetryData;
  final double accuracyScore;
  final bool isConnected;

  const TelemetryVisualizationWidget({
    super.key,
    required this.telemetryData,
    required this.accuracyScore,
    required this.isConnected,
  });

  @override
  State<TelemetryVisualizationWidget> createState() =>
      _TelemetryVisualizationWidgetState();
}

class _TelemetryVisualizationWidgetState
    extends State<TelemetryVisualizationWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return AppTheme.lightTheme.colorScheme.secondary;
    if (accuracy >= 60) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isConnected
              ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with connection status
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.isConnected
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 8),
              Text(
                widget.isConnected
                    ? 'IoT Glove Connected'
                    : 'Device Disconnected',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAccuracyColor(widget.accuracyScore)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.accuracyScore.toInt()}%',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: _getAccuracyColor(widget.accuracyScore),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Finger Position Indicators
          _buildFingerPositions(),

          SizedBox(height: 16),

          // Hand Orientation Display
          Row(
            children: [
              Expanded(child: _buildOrientationChart()),
              SizedBox(width: 16),
              Expanded(child: _buildAccuracyMeter()),
            ],
          ),

          SizedBox(height: 16),

          // Real-time feedback
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  Widget _buildFingerPositions() {
    final fingerData =
        widget.telemetryData['fingerPositions'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Finger Positions',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFingerIndicator('Thumb', fingerData['thumb'] ?? 0.0),
            _buildFingerIndicator('Index', fingerData['index'] ?? 0.0),
            _buildFingerIndicator('Middle', fingerData['middle'] ?? 0.0),
            _buildFingerIndicator('Ring', fingerData['ring'] ?? 0.0),
            _buildFingerIndicator('Pinky', fingerData['pinky'] ?? 0.0),
          ],
        ),
      ],
    );
  }

  Widget _buildFingerIndicator(String finger, double value) {
    final normalizedValue = (value / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 8,
              height: 40 * normalizedValue,
              decoration: BoxDecoration(
                color: _getAccuracyColor(value),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          finger,
          style: AppTheme.lightTheme.textTheme.labelSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOrientationChart() {
    final orientationData =
        widget.telemetryData['orientation'] as Map<String, dynamic>? ?? {};

    return Container(
      height: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hand Orientation',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
          SizedBox(height: 4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrientationValue('X', orientationData['x'] ?? 0.0),
                _buildOrientationValue('Y', orientationData['y'] ?? 0.0),
                _buildOrientationValue('Z', orientationData['z'] ?? 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationValue(String axis, double value) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            axis,
            style: AppTheme.lightTheme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value.toStringAsFixed(1),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyMeter() {
    return Container(
      height: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accuracy Score',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
          SizedBox(height: 4),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: widget.accuracyScore / 100,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getAccuracyColor(widget.accuracyScore),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    String feedbackText;
    Color feedbackColor;
    IconData feedbackIcon;

    if (!widget.isConnected) {
      feedbackText = 'Connect your IoT glove to start practicing';
      feedbackColor = AppTheme.lightTheme.colorScheme.outline;
      feedbackIcon = Icons.bluetooth_disabled;
    } else if (widget.accuracyScore >= 80) {
      feedbackText = 'Excellent! Your sign is accurate';
      feedbackColor = AppTheme.lightTheme.colorScheme.secondary;
      feedbackIcon = Icons.check_circle;
    } else if (widget.accuracyScore >= 60) {
      feedbackText = 'Good attempt! Adjust your finger positions';
      feedbackColor = AppTheme.lightTheme.colorScheme.tertiary;
      feedbackIcon = Icons.adjust;
    } else {
      feedbackText = 'Keep practicing! Watch the video again';
      feedbackColor = AppTheme.lightTheme.colorScheme.error;
      feedbackIcon = Icons.refresh;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: feedbackColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: feedbackIcon.codePoint.toString(),
            color: feedbackColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              feedbackText,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: feedbackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
