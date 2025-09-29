import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GestureDetectionOverlayWidget extends StatefulWidget {
  final Map<String, dynamic> targetPosition;
  final Map<String, dynamic> currentPosition;
  final bool isDetecting;
  final Function()? onRetry;

  const GestureDetectionOverlayWidget({
    super.key,
    required this.targetPosition,
    required this.currentPosition,
    required this.isDetecting,
    this.onRetry,
  });

  @override
  State<GestureDetectionOverlayWidget> createState() =>
      _GestureDetectionOverlayWidgetState();
}

class _GestureDetectionOverlayWidgetState
    extends State<GestureDetectionOverlayWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _arrowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _arrowController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDetecting
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.05),
                      AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Hand positions overlay
            Positioned.fill(
              child: CustomPaint(
                painter: HandPositionPainter(
                  targetPosition: widget.targetPosition,
                  currentPosition: widget.currentPosition,
                  isDetecting: widget.isDetecting,
                  pulseAnimation: _pulseAnimation,
                  arrowAnimation: _arrowAnimation,
                ),
              ),
            ),

            // Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.isDetecting ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.isDetecting
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
                    widget.isDetecting
                        ? 'Detecting Gesture...'
                        : 'Position Your Hands',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  Spacer(),
                  if (!widget.isDetecting)
                    GestureDetector(
                      onTap: widget.onRetry,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'refresh',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Retry',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Instructions overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildInstructions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final accuracy = _calculateAccuracy();
    String instruction;
    Color instructionColor;
    IconData instructionIcon;

    if (accuracy >= 90) {
      instruction = 'Perfect! Hold this position';
      instructionColor = AppTheme.lightTheme.colorScheme.secondary;
      instructionIcon = Icons.check_circle;
    } else if (accuracy >= 70) {
      instruction = 'Almost there! Minor adjustments needed';
      instructionColor = AppTheme.lightTheme.colorScheme.tertiary;
      instructionIcon = Icons.adjust;
    } else if (accuracy >= 50) {
      instruction = 'Getting closer! Keep adjusting';
      instructionColor = AppTheme.lightTheme.colorScheme.primary;
      instructionIcon = Icons.trending_up;
    } else {
      instruction = 'Follow the target position shown above';
      instructionColor = AppTheme.lightTheme.colorScheme.error;
      instructionIcon = Icons.my_location;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: instructionColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: instructionIcon.codePoint.toString(),
            color: instructionColor,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: instructionColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: instructionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${accuracy.toInt()}%',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: instructionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAccuracy() {
    // Mock accuracy calculation based on position differences
    final targetX = (widget.targetPosition['x'] as double?) ?? 0.0;
    final targetY = (widget.targetPosition['y'] as double?) ?? 0.0;
    final currentX = (widget.currentPosition['x'] as double?) ?? 0.0;
    final currentY = (widget.currentPosition['y'] as double?) ?? 0.0;

    final distance =
        ((targetX - currentX).abs() + (targetY - currentY).abs()) / 2;
    final accuracy = (100 - (distance * 10)).clamp(0.0, 100.0);

    return accuracy;
  }
}

class HandPositionPainter extends CustomPainter {
  final Map<String, dynamic> targetPosition;
  final Map<String, dynamic> currentPosition;
  final bool isDetecting;
  final Animation<double> pulseAnimation;
  final Animation<double> arrowAnimation;

  HandPositionPainter({
    required this.targetPosition,
    required this.currentPosition,
    required this.isDetecting,
    required this.pulseAnimation,
    required this.arrowAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Draw target position (green circle)
    final targetX = (targetPosition['x'] as double?) ?? size.width * 0.3;
    final targetY = (targetPosition['y'] as double?) ?? size.height * 0.4;

    paint.color = Colors.green.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(targetX, targetY),
      30 * pulseAnimation.value,
      paint,
    );

    paint.color = Colors.green;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(
      Offset(targetX, targetY),
      30,
      paint,
    );

    // Draw current position (blue circle)
    final currentX = (currentPosition['x'] as double?) ?? size.width * 0.7;
    final currentY = (currentPosition['y'] as double?) ?? size.height * 0.6;

    paint.color = Colors.blue.withValues(alpha: 0.3);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(currentX, currentY),
      25,
      paint,
    );

    paint.color = Colors.blue;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(
      Offset(currentX, currentY),
      25,
      paint,
    );

    // Draw adjustment arrow
    if (isDetecting) {
      _drawAdjustmentArrow(
          canvas, size, targetX, targetY, currentX, currentY, paint);
    }

    // Draw hand landmarks
    _drawHandLandmarks(canvas, size, paint);
  }

  void _drawAdjustmentArrow(Canvas canvas, Size size, double targetX,
      double targetY, double currentX, double currentY, Paint paint) {
    final arrowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.8 * arrowAnimation.value)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final arrowPath = Path();
    final dx = targetX - currentX;
    final dy = targetY - currentY;
    final distance = (dx * dx + dy * dy).sqrt();

    if (distance > 10) {
      final normalizedDx = dx / distance;
      final normalizedDy = dy / distance;

      final startX = currentX + normalizedDx * 30;
      final startY = currentY + normalizedDy * 30;
      final endX = targetX - normalizedDx * 35;
      final endY = targetY - normalizedDy * 35;

      arrowPath.moveTo(startX, startY);
      arrowPath.lineTo(endX, endY);

      // Arrow head
      final arrowHeadLength = 10.0;
      final arrowHeadAngle = 0.5;

      arrowPath.lineTo(
        endX -
            arrowHeadLength *
                (normalizedDx * cos(arrowHeadAngle) -
                    normalizedDy * sin(arrowHeadAngle)),
        endY -
            arrowHeadLength *
                (normalizedDy * cos(arrowHeadAngle) +
                    normalizedDx * sin(arrowHeadAngle)),
      );

      arrowPath.moveTo(endX, endY);
      arrowPath.lineTo(
        endX -
            arrowHeadLength *
                (normalizedDx * cos(-arrowHeadAngle) -
                    normalizedDy * sin(-arrowHeadAngle)),
        endY -
            arrowHeadLength *
                (normalizedDy * cos(-arrowHeadAngle) +
                    normalizedDx * sin(-arrowHeadAngle)),
      );

      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  void _drawHandLandmarks(Canvas canvas, Size size, Paint paint) {
    // Draw simplified hand landmarks for reference
    final landmarkPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw hand outline reference
    final handPath = Path();
    handPath.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.5),
      width: size.width * 0.3,
      height: size.height * 0.4,
    ));

    canvas.drawPath(handPath, landmarkPaint);

    // Draw finger reference points
    final fingerPoints = [
      Offset(size.width * 0.4, size.height * 0.3), // Thumb
      Offset(size.width * 0.45, size.height * 0.25), // Index
      Offset(size.width * 0.5, size.height * 0.2), // Middle
      Offset(size.width * 0.55, size.height * 0.25), // Ring
      Offset(size.width * 0.6, size.height * 0.3), // Pinky
    ];

    for (final point in fingerPoints) {
      canvas.drawCircle(point, 3, landmarkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double cos(double radians) => radians.cos();
double sin(double radians) => radians.sin();

extension on double {
  double cos() => this * 0.5; // Simplified for demo
  double sin() => this * 0.5; // Simplified for demo
  double sqrt() => this > 0 ? this * 0.5 : 0; // Simplified for demo
}
