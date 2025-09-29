import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PairingProgressWidget extends StatefulWidget {
  final Map<String, dynamic> selectedDevice;
  final PairingState pairingState;
  final String statusMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PairingProgressWidget({
    super.key,
    required this.selectedDevice,
    required this.pairingState,
    required this.statusMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  State<PairingProgressWidget> createState() => _PairingProgressWidgetState();
}

class _PairingProgressWidgetState extends State<PairingProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    if (widget.pairingState == PairingState.connecting ||
        widget.pairingState == PairingState.authenticating) {
      _progressAnimationController.repeat();
      _pulseAnimationController.repeat(reverse: true);
    } else {
      _progressAnimationController.stop();
      _pulseAnimationController.stop();
    }
  }

  @override
  void didUpdateWidget(PairingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pairingState != oldWidget.pairingState) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDeviceInfo(),
        SizedBox(height: 4.h),
        _buildPairingStatus(),
        SizedBox(height: 4.h),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.pairingState == PairingState.connecting ||
                        widget.pairingState == PairingState.authenticating
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomIconWidget(
                    iconName: _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 8.w,
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
                  widget.selectedDevice["name"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.selectedDevice["type"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildProgressIndicator(),
          SizedBox(height: 3.h),
          Text(
            widget.statusMessage,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _getDetailedStatusMessage(),
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    switch (widget.pairingState) {
      case PairingState.connecting:
      case PairingState.authenticating:
        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                value: null,
                strokeWidth: 3,
                color: _getStatusColor(),
                backgroundColor: _getStatusColor().withValues(alpha: 0.2),
              ),
            );
          },
        );
      case PairingState.connected:
        return Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.1),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 12.w,
            ),
          ),
        );
      case PairingState.failed:
        return Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 12.w,
            ),
          ),
        );
      default:
        return SizedBox(width: 20.w, height: 20.w);
    }
  }

  Widget _buildActionButtons() {
    switch (widget.pairingState) {
      case PairingState.connecting:
      case PairingState.authenticating:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: Text('Cancel'),
          ),
        );
      case PairingState.failed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRetry,
                child: Text('Retry'),
              ),
            ),
          ],
        );
      case PairingState.connected:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to calibration
            },
            child: Text('Continue to Calibration'),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Color _getStatusColor() {
    switch (widget.pairingState) {
      case PairingState.connecting:
      case PairingState.authenticating:
        return AppTheme.lightTheme.colorScheme.primary;
      case PairingState.connected:
        return AppTheme.lightTheme.colorScheme.secondary;
      case PairingState.failed:
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getStatusIcon() {
    switch (widget.pairingState) {
      case PairingState.connecting:
        return 'bluetooth_searching';
      case PairingState.authenticating:
        return 'security';
      case PairingState.connected:
        return 'bluetooth_connected';
      case PairingState.failed:
        return 'bluetooth_disabled';
      default:
        return 'bluetooth';
    }
  }

  String _getStatusText() {
    switch (widget.pairingState) {
      case PairingState.connecting:
        return 'Connecting';
      case PairingState.authenticating:
        return 'Authenticating';
      case PairingState.connected:
        return 'Connected';
      case PairingState.failed:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getDetailedStatusMessage() {
    switch (widget.pairingState) {
      case PairingState.connecting:
        return 'Establishing Bluetooth connection with your HastVani glove. This may take a few moments.';
      case PairingState.authenticating:
        return 'Verifying device credentials and establishing secure communication channel.';
      case PairingState.connected:
        return 'Successfully connected! Your glove is ready for calibration and learning sessions.';
      case PairingState.failed:
        return 'Connection failed. Please ensure your glove is powered on and in pairing mode.';
      default:
        return '';
    }
  }
}

enum PairingState {
  idle,
  connecting,
  authenticating,
  connected,
  failed,
}
