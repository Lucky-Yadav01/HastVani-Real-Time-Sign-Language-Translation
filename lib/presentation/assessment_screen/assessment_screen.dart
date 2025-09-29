import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/assessment_controls_widget.dart';
import './widgets/assessment_results_widget.dart';
import './widgets/assessment_timer_widget.dart';
import './widgets/gesture_feedback_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/question_display_widget.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Assessment state
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  int _skippedQuestions = 0;
  int _remainingSkips = 3;
  bool _isDetecting = false;
  bool _isProcessing = false;
  bool _showFeedback = false;
  bool _assessmentCompleted = false;
  bool _timerPaused = false;
  double? _currentAccuracy;
  String? _feedbackMessage;
  List<String>? _improvementSuggestions;
  DateTime? _assessmentStartTime;
  Duration _totalDuration = Duration(minutes: 30);

  // Mock assessment data
  final List<Map<String, dynamic>> _assessmentQuestions = [
    {
      "id": 1,
      "type": "Fingerspelling",
      "difficulty": 1,
      "prompt": "Spell the word 'HELLO' using fingerspelling",
      "description": "Use clear finger positions for each letter",
      "signText": "HELLO",
      "demoVideo":
          "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
      "expectedGesture": "fingerspelling_hello",
      "passingAccuracy": 0.8,
    },
    {
      "id": 2,
      "type": "Basic Signs",
      "difficulty": 2,
      "prompt": "Perform the sign for 'THANK YOU'",
      "description": "Start with your hand at your chin and move it forward",
      "demoImage":
          "https://images.pexels.com/photos/8613320/pexels-photo-8613320.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "expectedGesture": "thank_you",
      "passingAccuracy": 0.75,
    },
    {
      "id": 3,
      "type": "Numbers",
      "difficulty": 1,
      "prompt": "Show the number '5' using ASL",
      "description": "Hold up all five fingers with palm facing forward",
      "signText": "5",
      "expectedGesture": "number_five",
      "passingAccuracy": 0.85,
    },
    {
      "id": 4,
      "type": "Family Signs",
      "difficulty": 3,
      "prompt": "Sign the word 'MOTHER'",
      "description": "Touch your thumb to your chin with fingers spread",
      "demoVideo":
          "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
      "expectedGesture": "mother",
      "passingAccuracy": 0.7,
    },
    {
      "id": 5,
      "type": "Conversation",
      "difficulty": 3,
      "prompt": "Sign 'HOW ARE YOU?'",
      "description": "Combine the signs for HOW, ARE, and YOU in sequence",
      "demoImage":
          "https://images.pexels.com/photos/8613286/pexels-photo-8613286.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "expectedGesture": "how_are_you",
      "passingAccuracy": 0.75,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _assessmentStartTime = DateTime.now();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startGestureDetection() {
    setState(() {
      _isDetecting = true;
      _showFeedback = false;
      _currentAccuracy = null;
      _feedbackMessage = null;
      _improvementSuggestions = null;
    });

    // Simulate gesture detection process
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _isDetecting) {
        _processGestureResult();
      }
    });
  }

  void _processGestureResult() {
    // Simulate IoT glove sensor analysis
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final accuracy =
        (random / 100.0) * 0.4 + 0.6; // Random accuracy between 0.6-1.0
    final currentQuestion = _assessmentQuestions[_currentQuestionIndex];
    final passingAccuracy = currentQuestion['passingAccuracy'] as double;
    final isCorrect = accuracy >= passingAccuracy;

    setState(() {
      _isDetecting = false;
      _currentAccuracy = accuracy;
      _showFeedback = true;

      if (isCorrect) {
        _feedbackMessage = "Excellent! Your gesture was recognized correctly.";
        _improvementSuggestions = null;
      } else {
        _feedbackMessage =
            "Good attempt! Try to improve your hand positioning.";
        _improvementSuggestions = [
          "Keep your fingers more spread apart",
          "Hold the position for 2-3 seconds",
          "Ensure your palm faces the correct direction",
          "Make the movement more deliberate and clear"
        ];
      }
    });

    // Provide haptic feedback
    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _submitAnswer() {
    if (_currentAccuracy == null) {
      _startGestureDetection();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    Future.delayed(Duration(milliseconds: 1500), () {
      final currentQuestion = _assessmentQuestions[_currentQuestionIndex];
      final passingAccuracy = currentQuestion['passingAccuracy'] as double;
      final isCorrect = _currentAccuracy! >= passingAccuracy;

      setState(() {
        _isProcessing = false;
        if (isCorrect) {
          _correctAnswers++;
        } else {
          _incorrectAnswers++;
        }
      });

      _moveToNextQuestion();
    });
  }

  void _skipQuestion() {
    if (_remainingSkips > 0) {
      setState(() {
        _remainingSkips--;
        _skippedQuestions++;
      });
      _moveToNextQuestion();
    }
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _assessmentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentAccuracy = null;
        _showFeedback = false;
        _feedbackMessage = null;
        _improvementSuggestions = null;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAssessment();
    }
  }

  void _completeAssessment() {
    setState(() {
      _assessmentCompleted = true;
      _timerPaused = true;
    });

    HapticFeedback.mediumImpact();

    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _repeatDemo() {
    HapticFeedback.lightImpact();
    // Demo repeat logic is handled in QuestionDisplayWidget
  }

  void _retryAssessment() {
    setState(() {
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _incorrectAnswers = 0;
      _skippedQuestions = 0;
      _remainingSkips = 3;
      _assessmentCompleted = false;
      _timerPaused = false;
      _currentAccuracy = null;
      _showFeedback = false;
      _assessmentStartTime = DateTime.now();
    });

    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onTimeExpired() {
    if (!_assessmentCompleted) {
      _completeAssessment();
    }
  }

  Map<String, dynamic> _getAssessmentResults() {
    final totalQuestions = _assessmentQuestions.length;
    final overallScore = (_correctAnswers / totalQuestions) * 100;
    final timeTaken = _assessmentStartTime != null
        ? DateTime.now().difference(_assessmentStartTime!)
        : Duration.zero;

    return {
      'overallScore': overallScore,
      'correctAnswers': _correctAnswers,
      'incorrectAnswers': _incorrectAnswers,
      'skippedQuestions': _skippedQuestions,
      'totalQuestions': totalQuestions,
      'timeTaken':
          '${timeTaken.inMinutes.toString().padLeft(2, '0')}:${(timeTaken.inSeconds % 60).toString().padLeft(2, '0')}',
      'averageAccuracy': overallScore.toInt(),
      'passingThreshold': 80.0,
    };
  }

  double get _accuracyPercentage {
    final totalAnswered = _correctAnswers + _incorrectAnswers;
    if (totalAnswered == 0) return 0.0;
    return (_correctAnswers / totalAnswered) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Module Assessment',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 5.w,
          ),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
        actions: [
          if (!_assessmentCompleted)
            AssessmentTimerWidget(
              totalDuration: _totalDuration,
              onTimeExpired: _onTimeExpired,
              isPaused: _timerPaused,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            if (!_assessmentCompleted)
              Padding(
                padding: EdgeInsets.all(4.w),
                child: ProgressIndicatorWidget(
                  currentQuestion: _currentQuestionIndex + 1,
                  totalQuestions: _assessmentQuestions.length,
                  accuracyPercentage: _accuracyPercentage,
                  correctAnswers: _correctAnswers,
                  incorrectAnswers: _incorrectAnswers,
                ),
              ),

            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Assessment questions
                  ..._assessmentQuestions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        children: [
                          QuestionDisplayWidget(
                            question: question,
                            onRepeatDemo: _repeatDemo,
                          ),
                          SizedBox(height: 3.h),
                          GestureFeedbackWidget(
                            isDetecting: _isDetecting,
                            accuracyScore: _currentAccuracy,
                            feedbackMessage: _feedbackMessage,
                            improvementSuggestions: _improvementSuggestions,
                            showFeedback: _showFeedback,
                          ),
                          SizedBox(height: 10.h), // Space for bottom controls
                        ],
                      ),
                    );
                  }),

                  // Results screen
                  SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: AssessmentResultsWidget(
                      results: _getAssessmentResults(),
                      onRetryAssessment: _retryAssessment,
                      onContinue: () {
                        Navigator.pushReplacementNamed(
                            context, '/home-dashboard');
                      },
                      onViewDetailedResults: () {
                        // Navigate to detailed results screen
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: !_assessmentCompleted
          ? AssessmentControlsWidget(
              onSkipQuestion: _skipQuestion,
              onRepeatDemo: _repeatDemo,
              onSubmitAnswer: _submitAnswer,
              canSubmit: _currentAccuracy != null || _isDetecting,
              isProcessing: _isProcessing,
              remainingSkips: _remainingSkips,
            )
          : null,
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Exit Assessment?',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Text(
            'Your progress will be lost if you exit now. Are you sure you want to leave?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Stay'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
