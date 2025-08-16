import 'package:flutter/material.dart';
import '../../services/admob_service.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_question.dart';

import '../../constants/app_constants.dart';
import '../../widgets/ad_loading_status.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final QuizDifficulty difficulty;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AdMobService _adMobService = AdMobService.instance;
  final QuizService _quizService = QuizService();

  bool _isLoading = false;
  bool _isAnswered = false;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert string category back to enum and start quiz
      final category = QuizCategory.values.firstWhere(
        (c) => c.name == widget.category,
        orElse: () => QuizCategory.general,
      );

      _quizService.startQuiz(
        category: category.name, // Convert enum to string
        difficulty: widget.difficulty,
        questionCount: 10,
      );
      _loadNextQuestion();
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadNextQuestion() {
    final question = _quizService.currentQuestion;
    if (question != null) {
      setState(() {
        _isAnswered = false;
        _selectedAnswer = null;
        _isLoading = false;
      });
    } else {
      // Quiz completed
      _showResults();
    }
  }

  void _showResults() {
    final results = _quizService.getQuizResults();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          category: widget.category,
          score: results['score'] as int? ?? 0,
          totalQuestions: _quizService.currentSession?.questionCount ?? 0,
        ),
      ),
    );
  }

  void _submitAnswer(int selectedAnswer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = selectedAnswer;
      _isAnswered = true;
    });

    // Submit answer to quiz service (this will trigger ads)
    _quizService.submitAnswer(selectedAnswer);

    // Wait a moment then move to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (!_quizService.isQuizComplete) {
          _loadNextQuestion();
        } else {
          // Quiz completed
          _showResults();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    final currentQuestion = _quizService.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'No questions available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final sessionStats = _quizService.sessionStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quiz - ${widget.category}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(sessionStats['currentQuestionIndex'] as int? ?? 0) + 1}/${sessionStats['totalQuestions'] as int? ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Global Ad Loading Status
          const AdLoadingStatus(
            showDetails: false,
            showSpinner: true,
            customMessage: 'Preparing ads for your quiz...',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar
                  Flexible(
                    child: LinearProgressIndicator(
                      value:
                          ((sessionStats['currentQuestionIndex'] as int? ?? 0) +
                                  1) /
                              (sessionStats['totalQuestions'] as int? ?? 1),
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question
                  Text(
                    currentQuestion.question,
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Answer Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion.options.length,
                      itemBuilder: (context, index) {
                        return _buildOptionCard(
                          currentQuestion.options[index],
                          index,
                          currentQuestion.correctAnswer,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnswered || _selectedAnswer == null
                          ? null
                          : () => _submitAnswer(_selectedAnswer!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isAnswered ? 'Question Completed' : 'Submit Answer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Banner Ad
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, int optionIndex, int correctAnswer) {
    final isSelected = _selectedAnswer == optionIndex;
    final isCorrect = optionIndex == correctAnswer;
    final showResult = _isAnswered;

    Color cardColor = Colors.white;
    Color borderColor = AppColors.primary;

    if (showResult) {
      if (isCorrect) {
        cardColor = Colors.green[50]!;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        cardColor = Colors.red[50]!;
        borderColor = Colors.red;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: _isAnswered ? null : () => _submitAnswer(optionIndex),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  color: showResult && isCorrect ? Colors.green : null,
                ),
                child: Center(
                  child: showResult && isCorrect
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          String.fromCharCode(65 + optionIndex), // A, B, C, D
                          style: AppTextStyles.caption.copyWith(
                            color: borderColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: AppTextStyles.body1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    final bannerAd = _adMobService.getBottomBannerAd();

    if (bannerAd == null) {
      return const AdLoadingStatus(
        showDetails: false,
        showSpinner: false,
        customMessage: 'Ad Loading...',
      );
    }

    return Container(
      width: double.infinity,
      height: 50,
      child: bannerAd,
    );
  }
}
