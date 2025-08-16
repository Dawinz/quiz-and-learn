import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/task_model.dart';
import '../../services/ad_service.dart';

class TaskCompletionScreen extends StatefulWidget {
  final TaskModel task;

  const TaskCompletionScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskCompletionScreen> createState() => _TaskCompletionScreenState();
}

class _TaskCompletionScreenState extends State<TaskCompletionScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isCompleted = false;
  bool _isSubmitting = false;
  final List<int?> _userAnswers = [];
  final List<bool> _isCorrect = [];

  // Mock quiz questions - replace with real API data
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is 5 x 3?',
      'options': ['12', '15', '18', '20'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is 10 - 4?',
      'options': ['4', '5', '6', '7'],
      'correctAnswer': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _userAnswers.length = _questions.length;
    _isCorrect.length = _questions.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Task: ${widget.task.title}',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
          color: AppColors.textSecondary,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.padding),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Question Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    'Question ${_currentQuestionIndex + 1}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    _questions[_currentQuestionIndex]['question'],
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),

                  // Options
                  ...List.generate(
                    _questions[_currentQuestionIndex]['options'].length,
                    (index) => _buildOptionCard(index),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0)
                  const SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _userAnswers[_currentQuestionIndex] != null
                        ? _nextQuestion
                        : null,
                    child: Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Submit'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int optionIndex) {
    final isSelected = _userAnswers[_currentQuestionIndex] == optionIndex;
    final isAnswered = _userAnswers[_currentQuestionIndex] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
      child: InkWell(
        onTap: () {
          if (!isAnswered) {
            setState(() {
              _userAnswers[_currentQuestionIndex] = optionIndex;
            });
          }
        },
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.onPrimary : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.onPrimary : AppColors.border,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.spacingMedium),
              Expanded(
                child: Text(
                  _questions[_currentQuestionIndex]['options'][optionIndex],
                  style: AppTextStyles.body1.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitTask();
    }
  }

  Future<void> _submitTask() async {
    setState(() {
      _isSubmitting = true;
    });

    // Calculate score
    for (int i = 0; i < _questions.length; i++) {
      final userAnswer = _userAnswers[i];
      final correctAnswer = _questions[i]['correctAnswer'];
      _isCorrect[i] = userAnswer == correctAnswer;
      if (_isCorrect[i]) _score++;
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Show ad after task completion
    await AdService.instance.showAdAfterTaskCompletion();

    if (mounted) {
      setState(() {
        _isCompleted = true;
        _isSubmitting = false;
      });
    }
  }

  Widget _buildCompletionScreen() {
    final percentage = (_score / _questions.length) * 100;
    final isPassed = percentage >= 70;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Task Completed!',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isPassed ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.check : Icons.close,
                size: 60,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Result Text
            Text(
              isPassed ? 'Congratulations!' : 'Keep Trying!',
              style: AppTextStyles.headline1.copyWith(
                color: isPassed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            Text(
              isPassed
                  ? 'You have successfully completed the task!'
                  : 'You need to score at least 70% to pass.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    '$_score/${_questions.length}',
                    style: AppTextStyles.headline1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge),

            // Reward (if passed)
            if (isPassed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.padding),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 24,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSizes.spacingSmall),
                    Text(
                      'You earned ${widget.task.reward} coins!',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSizes.padding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Task?'),
        content: const Text(
            'Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      Navigator.pop(context);
    }
  }
}
