import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' show Platform;

import '../../core/app_export.dart';
import './widgets/calibration_widget.dart';
import './widgets/device_discovery_widget.dart';
import './widgets/pairing_progress_widget.dart';
import './widgets/setup_completion_widget.dart';

class BluetoothPairingWizard extends StatefulWidget {
  const BluetoothPairingWizard({super.key});

  @override
  State<BluetoothPairingWizard> createState() => _BluetoothPairingWizardState();
}

class _BluetoothPairingWizardState extends State<BluetoothPairingWizard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  bool _isScanning = false;
  PairingState _pairingState = PairingState.idle;
  String _statusMessage = '';
  Map<String, dynamic>? _selectedDevice;
  double _calibrationAccuracy = 0.0;
  bool _permissionsRequested = false;

  final List<String> _stepTitles = [
    'Discover Devices',
    'Connect Device',
    'Calibrate Sensors',
    'Setup Complete',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_permissionsRequested) {
      _permissionsRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestBluetoothPermissions();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestBluetoothPermissions() async {
    // Skip Bluetooth permissions on web platform
    if (kIsWeb) {
      _showWebBluetoothInfo();
      return;
    }

    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    try {
      Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        _showPermissionDialog();
      }
    } catch (e) {
      // Handle permission errors gracefully
      print('Permission request error: $e');
      _showWebBluetoothInfo();
    }
  }

  void _showWebBluetoothInfo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'web',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Web Platform',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bluetooth functionality is not available on web browsers. You can still use HastVani in mock mode for learning.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Web features include:',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildPermissionPoint('Video lessons and tutorials'),
                  _buildPermissionPoint('Progress tracking'),
                  _buildPermissionPoint('Mock gesture practice'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Continue to App'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'bluetooth',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Bluetooth Access',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HastVani needs Bluetooth access to connect with your IoT sensor gloves.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We use sensor data for:',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildPermissionPoint('Real-time gesture recognition'),
                  _buildPermissionPoint('Learning progress tracking'),
                  _buildPermissionPoint('Accuracy feedback and scoring'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Skip for Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestBluetoothPermissions();
            },
            child: Text('Grant Access'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgressAnimation();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgressAnimation();
    }
  }

  void _updateProgressAnimation() {
    _progressAnimationController
        .animateTo((_currentStep + 1) / _stepTitles.length);
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    // Simulate scanning duration
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void _onDeviceSelected(Map<String, dynamic> device) {
    setState(() {
      _selectedDevice = device;
      _pairingState = PairingState.connecting;
      _statusMessage = 'Connecting to ${device["name"]}...';
    });

    _nextStep();
    _simulatePairingProcess();
  }

  void _simulatePairingProcess() async {
    // Connecting phase
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _pairingState = PairingState.authenticating;
        _statusMessage = 'Authenticating device...';
      });
    }

    // Authentication phase
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _pairingState = PairingState.connected;
        _statusMessage = 'Successfully connected!';
      });

      HapticFeedback.mediumImpact();

      // Auto advance to calibration after brief pause
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          _nextStep();
        }
      });
    }
  }

  void _retryPairing() {
    setState(() {
      _pairingState = PairingState.connecting;
      _statusMessage = 'Retrying connection...';
    });
    _simulatePairingProcess();
  }

  void _cancelPairing() {
    setState(() {
      _selectedDevice = null;
      _pairingState = PairingState.idle;
      _statusMessage = '';
    });
    _previousStep();
  }

  void _onCalibrationComplete(bool success) {
    setState(() {
      _calibrationAccuracy = success ? 0.95 : 0.0;
    });

    if (success) {
      HapticFeedback.mediumImpact();
      _nextStep();
    }
  }

  void _testConnection() {
    // Test connection implementation
    HapticFeedback.lightImpact();
  }

  void _completeSetup() {
    HapticFeedback.mediumImpact();

    // Show success message and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text('Welcome to HastVani! Your learning journey begins now.'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  void _skipToMockMode() {
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'developer_mode',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text('Mock device mode enabled. You can still learn!'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: CustomIconWidget(
                  iconName: 'arrow_back_ios',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 5.w,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _previousStep();
                },
              )
            : IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 5.w,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),
        title: Text(
          _stepTitles[_currentStep],
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Center(
              child: Text(
                '${_currentStep + 1} of ${_stepTitles.length}',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildDiscoveryStep(),
                _buildPairingStep(),
                _buildCalibrationStep(),
                _buildCompletionStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _stepTitles.length - 1) SizedBox(width: 1.w),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
                minHeight: 0.5.h,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryStep() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: DeviceDiscoveryWidget(
        onDeviceSelected: _onDeviceSelected,
        isScanning: _isScanning,
        onStartScan: _startScanning,
        onStopScan: _stopScanning,
      ),
    );
  }

  Widget _buildPairingStep() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: _selectedDevice != null
          ? PairingProgressWidget(
              selectedDevice: _selectedDevice!,
              pairingState: _pairingState,
              statusMessage: _statusMessage,
              onRetry: _retryPairing,
              onCancel: _cancelPairing,
            )
          : Center(
              child: Text(
                'No device selected',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
    );
  }

  Widget _buildCalibrationStep() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: _selectedDevice != null
          ? CalibrationWidget(
              connectedDevice: _selectedDevice!,
              onCalibrationComplete: _onCalibrationComplete,
            )
          : Center(
              child: Text(
                'Device not connected',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: _selectedDevice != null
          ? SetupCompletionWidget(
              connectedDevice: _selectedDevice!,
              calibrationAccuracy: _calibrationAccuracy,
              onTestConnection: _testConnection,
              onComplete: _completeSetup,
              onSkipToMockMode: _skipToMockMode,
            )
          : Center(
              child: Text(
                'Setup incomplete',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
    );
  }
}
