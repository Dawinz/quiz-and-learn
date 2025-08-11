import 'package:flutter/material.dart';
import '../../models/quiz_history.dart';
import '../../models/quiz_question.dart';
import '../../constants/app_constants.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<QuizHistory> _quizHistory = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, today, week, month

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load actual quiz history from database
      // For now, create sample data
      await Future.delayed(const Duration(seconds: 1));

      _quizHistory = _getSampleQuizHistory();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz history: $e')),
        );
      }
    }
  }

  List<QuizHistory> _getSampleQuizHistory() {
    final now = DateTime.now();
    return [
      QuizHistory(
        id: '1',
        userId: 'user1',
        category: 'general',
        difficulty: QuizDifficulty.easy,
        score: 80,
        totalQuestions: 10,
        correctAnswers: 8,
        accuracy: 80.0,
        timeTaken: const Duration(minutes: 5, seconds: 30),
        completedAt: now.subtract(const Duration(hours: 2)),
        answers: [],
        pointsEarned: 80,
        isCompleted: true,
      ),
      QuizHistory(
        id: '2',
        userId: 'user1',
        category: 'science',
        difficulty: QuizDifficulty.medium,
        score: 120,
        totalQuestions: 10,
        correctAnswers: 9,
        accuracy: 90.0,
        timeTaken: const Duration(minutes: 7, seconds: 15),
        completedAt: now.subtract(const Duration(days: 1)),
        answers: [],
        pointsEarned: 120,
        isCompleted: true,
      ),
      QuizHistory(
        id: '3',
        userId: 'user1',
        category: 'history',
        difficulty: QuizDifficulty.hard,
        score: 150,
        totalQuestions: 10,
        correctAnswers: 7,
        accuracy: 70.0,
        timeTaken: const Duration(minutes: 12, seconds: 45),
        completedAt: now.subtract(const Duration(days: 3)),
        answers: [],
        pointsEarned: 150,
        isCompleted: true,
      ),
    ];
  }

  List<QuizHistory> _getFilteredHistory() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case 'today':
        return _quizHistory.where((quiz) {
          final quizDate = DateTime(quiz.completedAt.year,
              quiz.completedAt.month, quiz.completedAt.day);
          return quizDate.isAtSameMomentAs(today);
        }).toList();
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return _quizHistory
            .where((quiz) => quiz.completedAt.isAfter(weekAgo))
            .toList();
      case 'month':
        final monthAgo = today.subtract(const Duration(days: 30));
        return _quizHistory
            .where((quiz) => quiz.completedAt.isAfter(monthAgo))
            .toList();
      default:
        return _quizHistory;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return '🟢';
      case QuizDifficulty.medium:
        return '🟡';
      case QuizDifficulty.hard:
        return '🔴';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quiz History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('all', 'All Time'),
                    const SizedBox(width: 8),
                    _buildFilterChip('today', 'Today'),
                    const SizedBox(width: 8),
                    _buildFilterChip('week', 'This Week'),
                    const SizedBox(width: 8),
                    _buildFilterChip('month', 'This Month'),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Section
          if (filteredHistory.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total Quizzes',
                    '${filteredHistory.length}',
                    Icons.quiz,
                    AppColors.primary,
                  ),
                  _buildStatItem(
                    'Average Score',
                    '${(filteredHistory.fold(0.0, (sum, quiz) => sum + quiz.accuracy) / filteredHistory.length).round()}%',
                    Icons.score,
                    Colors.green,
                  ),
                  _buildStatItem(
                    'Total Points',
                    '${filteredHistory.fold(0, (sum, quiz) => sum + quiz.pointsEarned)}',
                    Icons.stars,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],

          // History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final quiz = filteredHistory[index];
                          return _buildHistoryCard(quiz);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onBackground,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(QuizHistory quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _getDifficultyColor(quiz.difficulty),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              quiz.difficulty
                                  .toString()
                                  .split('.')
                                  .last
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${quiz.score}/${quiz.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${quiz.correctAnswers}/${quiz.totalQuestions} correct',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar
            LinearProgressIndicator(
              value: quiz.correctAnswers / quiz.totalQuestions,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAccuracyColor(quiz.accuracy),
              ),
              minHeight: 6,
            ),

            const SizedBox(height: 12),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  'Accuracy',
                  '${quiz.accuracy.round()}%',
                  _getAccuracyColor(quiz.accuracy),
                ),
                _buildStatChip(
                  'Time',
                  _formatDuration(quiz.timeTaken),
                  Colors.blue,
                ),
                _buildStatChip(
                  'Points',
                  '+${quiz.pointsEarned}',
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              'Completed on ${_formatDate(quiz.completedAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No quiz history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first quiz to see your history here!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final quizDate = DateTime(date.year, date.month, date.day);

    if (quizDate.isAtSameMomentAs(today)) {
      return 'Today at ${_formatTime(date)}';
    } else if (quizDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
