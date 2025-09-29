import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';

class QuestionDisplayWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final VoidCallback? onRepeatDemo;

  const QuestionDisplayWidget({
    super.key,
    required this.question,
    this.onRepeatDemo,
  });

  @override
  State<QuestionDisplayWidget> createState() => _QuestionDisplayWidgetState();
}

class _QuestionDisplayWidgetState extends State<QuestionDisplayWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(QuestionDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question['id'] != oldWidget.question['id']) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  Future<void> _initializeVideo() async {
    if (widget.question['demoVideo'] != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.question['demoVideo'] as String),
      );

      try {
        await _videoController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController!.play();
      } catch (e) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
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
          // Question header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  widget.question['type'] as String? ?? 'Sign Recognition',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Spacer(),
              if (widget.question['difficulty'] != null)
                Row(
                  children: List.generate(
                    3,
                    (index) => CustomIconWidget(
                      iconName: 'star',
                      color: index < (widget.question['difficulty'] as int)
                          ? AppTheme.lightTheme.colorScheme.tertiary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      size: 4.w,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // Question text
          Text(
            widget.question['prompt'] as String? ??
                'Perform the sign shown in the demonstration',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          if (widget.question['description'] != null) ...[
            SizedBox(height: 2.h),
            Text(
              widget.question['description'] as String,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Video demonstration or image
          if (widget.question['demoVideo'] != null)
            _buildVideoDemo()
          else if (widget.question['demoImage'] != null)
            _buildImageDemo()
          else
            _buildTextDemo(),

          SizedBox(height: 3.h),

          // Repeat demo button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_videoController != null && _isVideoInitialized) {
                  _videoController!.seekTo(Duration.zero);
                  _videoController!.play();
                }
                widget.onRepeatDemo?.call();
              },
              icon: CustomIconWidget(
                iconName: 'replay',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 4.w,
              ),
              label: Text('Repeat Demo'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDemo() {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: _isVideoInitialized && _videoController != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.w),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                if (!_videoController!.value.isPlaying)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'play_arrow',
                        color: Colors.white,
                        size: 8.w,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 2.h,
                  left: 4.w,
                  right: 4.w,
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: AppTheme.lightTheme.colorScheme.primary,
                      bufferedColor: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
    );
  }

  Widget _buildImageDemo() {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.w),
        child: CustomImageWidget(
          imageUrl: widget.question['demoImage'] as String,
          width: double.infinity,
          height: 40.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextDemo() {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'sign_language',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              widget.question['signText'] as String? ?? 'HELLO',
              style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Perform this sign',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
