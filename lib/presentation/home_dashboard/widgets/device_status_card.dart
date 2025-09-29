import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceStatusCard extends StatelessWidget {
  final bool isConnected;
  final int batteryLevel;
  final int signalStrength;
  final VoidCallback onConnectPressed;

  const DeviceStatusCard({
    super.key,
    required this.isConnected,
    required this.batteryLevel,
    required this.signalStrength,
    required this.onConnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName:
                    isConnected ? 'bluetooth_connected' : 'bluetooth_disabled',
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.outline,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? 'IoT Glove Connected'
                          : 'IoT Glove Disconnected',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      isConnected
                          ? 'Ready for sign detection'
                          : 'Tap to connect your device',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator(
                    'Battery',
                    '$batteryLevel%',
                    'battery_${_getBatteryIcon(batteryLevel)}',
                    _getBatteryColor(batteryLevel),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildStatusIndicator(
                    'Signal',
                    '${signalStrength}%',
                    'signal_cellular_${_getSignalIcon(signalStrength)}',
                    _getSignalColor(signalStrength),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConnectPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected
                    ? AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: isConnected
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isConnected ? 'Device Settings' : 'Connect Device',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
      String label, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 10.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBatteryIcon(int level) {
    if (level > 80) return 'full';
    if (level > 60) return '6_bar';
    if (level > 40) return '4_bar';
    if (level > 20) return '2_bar';
    return '1_bar';
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return AppTheme.lightTheme.colorScheme.secondary;
    if (level > 20) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _getSignalIcon(int strength) {
    if (strength > 80) return '4_bar';
    if (strength > 60) return '3_bar';
    if (strength > 40) return '2_bar';
    if (strength > 20) return '1_bar';
    return '0_bar';
  }

  Color _getSignalColor(int strength) {
    if (strength > 50) return AppTheme.lightTheme.colorScheme.secondary;
    if (strength > 20) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }
}
