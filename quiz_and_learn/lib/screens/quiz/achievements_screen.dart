import 'package:flutter/material.dart';
import '../../models/quiz_achievement.dart';
import '../../constants/app_constants.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<QuizAchievement> _userAchievements = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, unlocked, locked

  @override
  void initState() {
    super.initState();
    _loadUserAchievements();
  }

  Future<void> _loadUserAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load actual user achievements from database
      // For now, create sample data
      await Future.delayed(const Duration(seconds: 1));

      _userAchievements = _getSampleAchievements();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading achievements: $e')),
        );
      }
    }
  }

  List<QuizAchievement> _getSampleAchievements() {
    return [
      QuizAchievement(
        id: 'first_quiz',
        title: 'First Steps',
        description: 'Complete your first quiz',
        iconPath: 'assets/icons/special_bronze.png',
        type: AchievementType.special,
        tier: AchievementTier.bronze,
        requirement: 1,
        pointsReward: 25,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      QuizAchievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Complete quizzes for 3 days in a row',
        iconPath: 'assets/icons/streak_bronze.png',
        type: AchievementType.streak,
        tier: AchievementTier.bronze,
        requirement: 3,
        pointsReward: 50,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      QuizAchievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Complete quizzes for 7 days in a row',
        iconPath: 'assets/icons/streak_silver.png',
        type: AchievementType.streak,
        tier: AchievementTier.silver,
        requirement: 7,
        pointsReward: 100,
        isUnlocked: false,
      ),
      QuizAchievement(
        id: 'score_1000',
        title: 'Point Collector',
        description: 'Earn 1,000 total points',
        iconPath: 'assets/icons/score_bronze.png',
        type: AchievementType.score,
        tier: AchievementTier.bronze,
        requirement: 1000,
        pointsReward: 50,
        isUnlocked: false,
      ),
    ];
  }

  List<QuizAchievement> _getFilteredAchievements() {
    switch (_selectedFilter) {
      case 'unlocked':
        return _userAchievements
            .where((achievement) => achievement.isUnlocked)
            .toList();
      case 'locked':
        return _userAchievements
            .where((achievement) => !achievement.isUnlocked)
            .toList();
      default:
        return _userAchievements;
    }
  }

  List<QuizAchievement> _getAllAchievements() {
    // Combine user achievements with all available achievements
    final allAchievements = List<QuizAchievement>.from(QuizAchievements.all);

    // Update with user's unlocked status
    for (final userAchievement in _userAchievements) {
      final index =
          allAchievements.indexWhere((a) => a.id == userAchievement.id);
      if (index != -1) {
        allAchievements[index] = userAchievement;
      }
    }

    return allAchievements;
  }

  List<QuizAchievement> _getFilteredAllAchievements() {
    final allAchievements = _getAllAchievements();

    switch (_selectedFilter) {
      case 'unlocked':
        return allAchievements
            .where((achievement) => achievement.isUnlocked)
            .toList();
      case 'locked':
        return allAchievements
            .where((achievement) => !achievement.isUnlocked)
            .toList();
      default:
        return allAchievements;
    }
  }

  int _getUnlockedCount() {
    return _userAchievements
        .where((achievement) => achievement.isUnlocked)
        .length;
  }

  int _getTotalCount() {
    return QuizAchievements.all.length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredAchievements = _getFilteredAllAchievements();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Section
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: _getTotalCount() > 0
                      ? _getUnlockedCount() / _getTotalCount()
                      : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: 16),

                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${_getUnlockedCount()}/${_getTotalCount()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                  'Filter Achievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('all', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('unlocked', 'Unlocked'),
                    const SizedBox(width: 8),
                    _buildFilterChip('locked', 'Locked'),
                  ],
                ),
              ],
            ),
          ),

          // Achievements List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : filteredAchievements.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = filteredAchievements[index];
                          return _buildAchievementCard(achievement);
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

  Widget _buildAchievementCard(QuizAchievement achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: achievement.isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: achievement.isUnlocked
            ? BorderSide(color: achievement.tierColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: achievement.isUnlocked
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    achievement.tierColor.withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Achievement Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.tierColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: achievement.isUnlocked
                      ? Icon(
                          _getAchievementIcon(achievement.type),
                          color: achievement.tierColor,
                          size: 32,
                        )
                      : Icon(
                          Icons.lock,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Achievement Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: achievement.isUnlocked
                                  ? AppColors.onBackground
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: achievement.tierColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              achievement.tierName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: achievement.tierColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: achievement.isUnlocked
                            ? Colors.grey[600]
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${achievement.pointsReward} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (achievement.isUnlocked &&
                            achievement.unlockedAt != null) ...[
                          Text(
                            'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Requirement: ${achievement.requirement}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the filter or complete more quizzes!',
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

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.score:
        return Icons.stars;
      case AchievementType.category:
        return Icons.category;
      case AchievementType.difficulty:
        return Icons.trending_up;
      case AchievementType.speed:
        return Icons.speed;
      case AchievementType.accuracy:
        return Icons.check_circle;
      case AchievementType.special:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final achievementDate = DateTime(date.year, date.month, date.day);

    if (achievementDate.isAtSameMomentAs(today)) {
      return 'today';
    } else if (achievementDate.isAtSameMomentAs(yesterday)) {
      return 'yesterday';
    } else {
      final difference = now.difference(date).inDays;
      if (difference < 7) {
        return '$difference days ago';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return '$weeks weeks ago';
      } else {
        final months = (difference / 30).floor();
        return '$months months ago';
      }
    }
  }
}
