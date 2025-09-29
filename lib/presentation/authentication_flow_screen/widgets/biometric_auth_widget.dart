import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiometricAuthWidget extends StatefulWidget {
  final Function(bool) onLoading;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const BiometricAuthWidget({
    super.key,
    required this.onLoading,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget>
    with SingleTickerProviderStateMixin {
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricType = 'fingerprint';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _setupPulseAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Mock checking biometric availability
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isBiometricAvailable = true;
        _isBiometricEnabled = true;
        // Mock determining biometric type based on platform
        _biometricType = Theme.of(context).platform == TargetPlatform.iOS
            ? 'face_id'
            : 'fingerprint';
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
        _isBiometricEnabled = false;
      });
    }
  }

  Future<void> _handleBiometricAuth() async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return;

    widget.onLoading(true);
    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication success
      HapticFeedback.heavyImpact();
      _pulseController.stop();
      widget.onSuccess();
    } catch (e) {
      HapticFeedback.selectionClick();
      widget.onError('Biometric authentication failed: ${e.toString()}');
    } finally {
      _pulseController.stop();
      widget.onLoading(false);
    }
  }

  IconData _getBiometricIcon() {
    switch (_biometricType) {
      case 'face_id':
        return Icons.face_rounded;
      case 'fingerprint':
        return Icons.fingerprint_rounded;
      default:
        return Icons.security_rounded;
    }
  }

  String _getBiometricLabel() {
    switch (_biometricType) {
      case 'face_id':
        return 'Face ID';
      case 'fingerprint':
        return 'Touch ID';
      default:
        return 'Biometric';
    }
  }

  String _getBiometricDescription() {
    switch (_biometricType) {
      case 'face_id':
        return 'Look at your device to authenticate';
      case 'fingerprint':
        return 'Place your finger on the sensor';
      default:
        return 'Use your device biometric';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBiometricAvailable) {
      return _buildUnavailableState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getBiometricIcon(),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Biometric Authentication',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quick and secure access with ${_getBiometricLabel()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildBiometricButton(),
            const SizedBox(height: 16),
            _buildBiometricFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(60),
            child: InkWell(
              onTap: _handleBiometricAuth,
              borderRadius: BorderRadius.circular(60),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getBiometricIcon(),
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBiometricLabel(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiometricFeatures() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Instant access in under 2 seconds',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getBiometricDescription(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.fingerprint_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'Biometric Authentication Unavailable',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please set up biometric authentication in your device settings to enable quick access.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
