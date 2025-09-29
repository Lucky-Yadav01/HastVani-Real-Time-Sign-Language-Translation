import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ProgressTrackingWidget extends StatefulWidget {
  final int attempts;
  final double accuracyPercentage;
  final Duration timeSpent;
  final List<Map<String, dynamic>> attemptHistory;
  final String currentSign;

  const ProgressTrackingWidget({
    super.key,
    required this.attempts,
    required this.accuracyPercentage,
    required this.timeSpent,
    required this.attemptHistory,
    required this.currentSign,
  });

  @override
  State<ProgressTrackingWidget> createState() => _ProgressTrackingWidgetState();
}

class _ProgressTrackingWidgetState extends State<ProgressTrackingWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.accuracyPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(ProgressTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accuracyPercentage != widget.accuracyPercentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.accuracyPercentage / 100,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return AppTheme.lightTheme.colorScheme.secondary;
    if (accuracy >= 60) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
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
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Practice Progress',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.currentSign,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'Attempts', widget.attempts.toString(), 'refresh')),
              SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Time', _formatDuration(widget.timeSpent), 'timer')),
              SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'Best', '${widget.accuracyPercentage.toInt()}%', 'star')),
            ],
          ),

          SizedBox(height: 16),

          // Accuracy Progress
          _buildAccuracyProgress(),

          SizedBox(height: 16),

          // Attempt History Chart
          if (widget.attemptHistory.isNotEmpty) _buildAttemptHistoryChart(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 18,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Accuracy',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: _getAccuracyColor(widget.accuracyPercentage),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: 8),

        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.8 *
                      _progressAnimation.value,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getAccuracyColor(widget.accuracyPercentage),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 8),

        // Accuracy milestones
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMilestone('60%', widget.accuracyPercentage >= 60),
            _buildMilestone('80%', widget.accuracyPercentage >= 80),
            _buildMilestone('95%', widget.accuracyPercentage >= 95),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestone(String label, bool achieved) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: achieved
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: achieved
              ? CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 12,
                )
              : null,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: achieved
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.outline,
            fontWeight: achieved ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptHistoryChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attempt History',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt() + 1}',
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (widget.attemptHistory.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: widget.attemptHistory.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      (entry.value['accuracy'] as double?) ?? 0.0,
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: _getAccuracyColor(spot.y),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
