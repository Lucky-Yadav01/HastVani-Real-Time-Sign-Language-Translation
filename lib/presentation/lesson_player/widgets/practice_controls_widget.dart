import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class PracticeControlsWidget extends StatefulWidget {
  final Function()? onWatchAgain;
  final Function()? onTryNow;
  final Function()? onNextSign;
  final Function()? onPreviousSign;
  final bool canGoNext;
  final bool canGoPrevious;
  final bool isPlaying;
  final bool isPracticing;

  const PracticeControlsWidget({
    super.key,
    this.onWatchAgain,
    this.onTryNow,
    this.onNextSign,
    this.onPreviousSign,
    this.canGoNext = true,
    this.canGoPrevious = true,
    this.isPlaying = false,
    this.isPracticing = false,
  });

  @override
  State<PracticeControlsWidget> createState() => _PracticeControlsWidgetState();
}

class _PracticeControlsWidgetState extends State<PracticeControlsWidget>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _onButtonPressed(VoidCallback? onPressed) {
    if (onPressed != null) {
      HapticFeedback.lightImpact();
      _buttonController.forward().then((_) {
        _buttonController.reverse();
      });
      onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primary action buttons
          Row(
            children: [
              // Watch Again Button
              Expanded(
                child: _buildActionButton(
                  label: 'Watch Again',
                  icon: 'replay',
                  onPressed: widget.onWatchAgain,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                  foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
                  isSecondary: true,
                ),
              ),

              SizedBox(width: 12),

              // Try Now Button (Primary)
              Expanded(
                flex: 2,
                child: _buildActionButton(
                  label: widget.isPracticing ? 'Practicing...' : 'Try Now',
                  icon: widget.isPracticing ? 'stop' : 'gesture',
                  onPressed: widget.isPracticing ? null : widget.onTryNow,
                  backgroundColor: widget.isPracticing
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  isPrimary: true,
                  isLoading: widget.isPracticing,
                ),
              ),

              SizedBox(width: 12),

              // Next Sign Button
              Expanded(
                child: _buildActionButton(
                  label: 'Next Sign',
                  icon: 'arrow_forward',
                  onPressed: widget.canGoNext ? widget.onNextSign : null,
                  backgroundColor: widget.canGoNext
                      ? AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                  foregroundColor: widget.canGoNext
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.outline,
                  isSecondary: true,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Sign
              _buildNavigationButton(
                icon: 'skip_previous',
                label: 'Previous',
                onPressed: widget.canGoPrevious ? widget.onPreviousSign : null,
                isEnabled: widget.canGoPrevious,
              ),

              // Progress indicator placeholder
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 24, // 60% progress
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Next Sign
              _buildNavigationButton(
                icon: 'skip_next',
                label: 'Next',
                onPressed: widget.canGoNext ? widget.onNextSign : null,
                isEnabled: widget.canGoNext,
              ),
            ],
          ),

          SizedBox(height: 12),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    bool isPrimary = false,
    bool isSecondary = false,
    bool isLoading = false,
  }) {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: onPressed != null ? _buttonAnimation.value : 1.0,
          child: Container(
            height: 48,
            child: ElevatedButton(
              onPressed:
                  onPressed != null ? () => _onButtonPressed(onPressed) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: isPrimary ? 2 : 0,
                shadowColor: AppTheme.lightTheme.colorScheme.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSecondary
                      ? BorderSide(
                          color: foregroundColor.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(foregroundColor),
                      ),
                    )
                  else
                    CustomIconWidget(
                      iconName: icon,
                      color: foregroundColor,
                      size: 18,
                    ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight:
                            isPrimary ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton({
    required String icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onPressed != null ? () => _onButtonPressed(onPressed) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickAction(
          icon: 'bookmark_outline',
          label: 'Bookmark',
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle bookmark
          },
        ),
        _buildQuickAction(
          icon: 'slow_motion_video',
          label: 'Slow Motion',
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle slow motion
          },
        ),
        _buildQuickAction(
          icon: 'help_outline',
          label: 'Help',
          onPressed: () {
            HapticFeedback.lightImpact();
            _showHelpDialog();
          },
        ),
        _buildQuickAction(
          icon: 'share',
          label: 'Share',
          onPressed: () {
            HapticFeedback.lightImpact();
            // Handle share
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              size: 18,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Practice Help',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to practice:',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Text(
              '1. Watch the instructor video carefully\n'
              '2. Connect your IoT glove for real-time feedback\n'
              '3. Try to match the target hand position\n'
              '4. Practice until you achieve 80% accuracy',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}
