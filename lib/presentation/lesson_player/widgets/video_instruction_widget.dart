import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';

class VideoInstructionWidget extends StatefulWidget {
  final String videoUrl;
  final String lessonTitle;
  final Function(bool)? onPlayPauseChanged;

  const VideoInstructionWidget({
    super.key,
    required this.videoUrl,
    required this.lessonTitle,
    this.onPlayPauseChanged,
  });

  @override
  State<VideoInstructionWidget> createState() => _VideoInstructionWidgetState();
}

class _VideoInstructionWidgetState extends State<VideoInstructionWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  double _playbackSpeed = 1.0;
  bool _showCaptions = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle video initialization error
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        widget.onPlayPauseChanged?.call(false);
      } else {
        _controller!.play();
        widget.onPlayPauseChanged?.call(true);
      }
      setState(() {});
    }
  }

  void _changePlaybackSpeed(double speed) {
    if (_controller != null) {
      _controller!.setPlaybackSpeed(speed);
      setState(() {
        _playbackSpeed = speed;
      });
    }
  }

  void _toggleCaptions() {
    setState(() {
      _showCaptions = !_showCaptions;
    });
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Playback Speed',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 16),
              ...([0.5, 0.75, 1.0, 1.25, 1.5, 2.0]).map((speed) => ListTile(
                    title: Text('${speed}x'),
                    trailing: _playbackSpeed == speed
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      _changePlaybackSpeed(speed);
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video Player
            if (_isInitialized && _controller != null)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: _isInitialized == false && _controller == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'error_outline',
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Video unavailable',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                  ),
                ),
              ),

            // Controls Overlay
            if (_showControls && _isInitialized)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top Controls
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.lessonTitle,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleCaptions,
                                icon: CustomIconWidget(
                                  iconName: _showCaptions
                                      ? 'closed_caption'
                                      : 'closed_caption_off',
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: _showSpeedOptions,
                                icon: CustomIconWidget(
                                  iconName: 'speed',
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // Center Play Button
                        Center(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: _controller?.value.isPlaying == true
                                    ? 'pause'
                                    : 'play_arrow',
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        Spacer(),

                        // Bottom Controls
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Progress Bar
                              if (_controller != null)
                                VideoProgressIndicator(
                                  _controller!,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    bufferedColor:
                                        Colors.white.withValues(alpha: 0.3),
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),

                              SizedBox(height: 8),

                              // Time and Speed Display
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _controller != null
                                        ? _formatDuration(
                                            _controller!.value.position)
                                        : '0:00',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${_playbackSpeed}x',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _controller != null
                                        ? _formatDuration(
                                            _controller!.value.duration)
                                        : '0:00',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Captions Overlay
            if (_showCaptions && _isInitialized)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Watch how the instructor forms the sign with their hands.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
