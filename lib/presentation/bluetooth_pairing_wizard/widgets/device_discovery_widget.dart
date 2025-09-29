import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceDiscoveryWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDeviceSelected;
  final bool isScanning;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;

  const DeviceDiscoveryWidget({
    super.key,
    required this.onDeviceSelected,
    required this.isScanning,
    required this.onStartScan,
    required this.onStopScan,
  });

  @override
  State<DeviceDiscoveryWidget> createState() => _DeviceDiscoveryWidgetState();
}

class _DeviceDiscoveryWidgetState extends State<DeviceDiscoveryWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  final List<Map<String, dynamic>> _discoveredDevices = [
    {
      "id": "glove_001",
      "name": "HastVani Glove Pro",
      "type": "IoT Sensor Glove",
      "signalStrength": -45,
      "batteryLevel": 85,
      "isConnectable": true,
      "lastSeen": DateTime.now().subtract(Duration(seconds: 5)),
      "deviceIcon": "sensors",
    },
    {
      "id": "glove_002",
      "name": "HastVani Glove Lite",
      "type": "Basic Sensor Glove",
      "signalStrength": -62,
      "batteryLevel": 67,
      "isConnectable": true,
      "lastSeen": DateTime.now().subtract(Duration(seconds: 12)),
      "deviceIcon": "sensors",
    },
    {
      "id": "glove_003",
      "name": "HastVani Glove Dev",
      "type": "Development Kit",
      "signalStrength": -78,
      "batteryLevel": 23,
      "isConnectable": false,
      "lastSeen": DateTime.now().subtract(Duration(minutes: 2)),
      "deviceIcon": "developer_mode",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isScanning) {
      _scanAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(DeviceDiscoveryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _scanAnimationController.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _scanAnimationController.stop();
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScanHeader(),
        SizedBox(height: 3.h),
        widget.isScanning ? _buildScanningIndicator() : _buildDeviceList(),
      ],
    );
  }

  Widget _buildScanHeader() {
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
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'bluetooth_searching',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover IoT Gloves',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.isScanning
                      ? 'Scanning for available devices...'
                      : 'Tap scan to find nearby HastVani gloves',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            onPressed:
                widget.isScanning ? widget.onStopScan : widget.onStartScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isScanning
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.isScanning ? 'Stop' : 'Scan',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Container(
      height: 30.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    Transform.rotate(
                      angle: _scanAnimation.value * 2 * 3.14159,
                      child: CustomIconWidget(
                        iconName: 'bluetooth_searching',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 3.h),
          Text(
            'Scanning for devices...',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Make sure your HastVani glove is powered on\nand in pairing mode',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Devices',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _discoveredDevices.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            final device = _discoveredDevices[index];
            return _buildDeviceCard(device);
          },
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final bool isConnectable = device["isConnectable"] as bool;
    final int signalStrength = device["signalStrength"] as int;
    final int batteryLevel = device["batteryLevel"] as int;

    return GestureDetector(
      onTap: isConnectable
          ? () {
              HapticFeedback.lightImpact();
              widget.onDeviceSelected(device);
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnectable
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
          ),
          boxShadow: isConnectable
              ? [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isConnectable
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: device["deviceIcon"] as String,
                color: isConnectable
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          device["name"] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isConnectable
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                      ),
                      if (!isConnectable)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Low Battery',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    device["type"] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isConnectable
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7)
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildSignalStrengthIndicator(
                          signalStrength, isConnectable),
                      SizedBox(width: 4.w),
                      _buildBatteryIndicator(batteryLevel, isConnectable),
                    ],
                  ),
                ],
              ),
            ),
            if (isConnectable) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.outline,
                size: 4.w,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStrengthIndicator(int signalStrength, bool isConnectable) {
    int bars = 0;
    if (signalStrength >= -50)
      bars = 4;
    else if (signalStrength >= -60)
      bars = 3;
    else if (signalStrength >= -70)
      bars = 2;
    else
      bars = 1;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'wifi',
          color: isConnectable
              ? (bars >= 3
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.outline)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
          size: 3.5.w,
        ),
        SizedBox(width: 1.w),
        Text(
          '${signalStrength}dBm',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isConnectable
                ? AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryIndicator(int batteryLevel, bool isConnectable) {
    Color batteryColor;
    String batteryIcon;

    if (batteryLevel >= 80) {
      batteryColor = AppTheme.lightTheme.colorScheme.secondary;
      batteryIcon = 'battery_full';
    } else if (batteryLevel >= 50) {
      batteryColor = AppTheme.lightTheme.colorScheme.tertiary;
      batteryIcon = 'battery_5_bar';
    } else if (batteryLevel >= 20) {
      batteryColor = AppTheme.lightTheme.colorScheme.tertiary;
      batteryIcon = 'battery_3_bar';
    } else {
      batteryColor = AppTheme.lightTheme.colorScheme.error;
      batteryIcon = 'battery_1_bar';
    }

    if (!isConnectable) {
      batteryColor = batteryColor.withValues(alpha: 0.5);
    }

    return Row(
      children: [
        CustomIconWidget(
          iconName: batteryIcon,
          color: batteryColor,
          size: 3.5.w,
        ),
        SizedBox(width: 1.w),
        Text(
          '${batteryLevel}%',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isConnectable
                ? AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
