import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_question.dart';
import '../../services/quiz_service.dart';
import '../../services/admob_service.dart';
import '../../widgets/ad_loading_overlay.dart';
import '../../widgets/ad_loading_status.dart';
import 'quiz_screen.dart';

class QuizDifficultyScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizDifficultyScreen({
    super.key,
    required this.category,
  });

  @override
  State<QuizDifficultyScreen> createState() => _QuizDifficultyScreenState();
}

class _QuizDifficultyScreenState extends State<QuizDifficultyScreen> {
  final QuizService _quizService = QuizService();
  final AdMobService _adMobService = AdMobService.instance;
  bool _isInterstitialAdLoading = false;

  @override
  void initState() {
    super.initState();
    _showInterstitialAd();
  }

  Future<void> _showInterstitialAd() async {
    setState(() {
      _isInterstitialAdLoading = true;
    });

    try {
      await _adMobService.showInterstitialBetweenLevels();
    } catch (e) {
      // Ad failed to show, continue without it
    } finally {
      setState(() {
        _isInterstitialAdLoading = false;
      });
    }
  }

  void _startQuiz(QuizDifficulty difficulty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          category: widget.category.name,
          difficulty: difficulty,
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _startQuiz(difficulty),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.headline3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.onBackground.withAlpha(179),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$questionCount Questions',
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionCounts = _quizService.availableQuestionCounts;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} - Difficulty'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          if (_isInterstitialAdLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Global Ad Loading Status
          const AdLoadingStatus(
            showDetails: true,
            showSpinner: true,
            customMessage: 'Preparing ads for your quiz experience...',
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.background],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Choose Difficulty Level',
                          style: AppTextStyles.headline2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select how challenging you want your quiz to be',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.onBackground.withAlpha(179),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          children: [
                            _buildDifficultyCard(
                              icon: Icons.school,
                              color: AppColors.success,
                              title: 'Easy',
                              description:
                                  'Perfect for beginners. Simple questions to get you started.',
                              difficulty: QuizDifficulty.easy,
                              questionCount: questionCounts['easy'] ?? 0,
                            ),
                            _buildDifficultyCard(
                              icon: Icons.psychology,
                              color: AppColors.warning,
                              title: 'Medium',
                              description:
                                  'A balanced challenge. Test your knowledge with moderate questions.',
                              difficulty: QuizDifficulty.medium,
                              questionCount: questionCounts['medium'] ?? 0,
                            ),
                            _buildDifficultyCard(
                              icon: Icons.emoji_events,
                              color: AppColors.error,
                              title: 'Hard',
                              description:
                                  'For experts only. Push your limits with challenging questions.',
                              difficulty: QuizDifficulty.hard,
                              questionCount: questionCounts['hard'] ?? 0,
                            ),
                            _buildDifficultyCard(
                              icon: Icons.shuffle,
                              color: AppColors.info,
                              title: 'Mixed',
                              description:
                                  'All difficulty levels combined for a varied experience.',
                              difficulty: QuizDifficulty
                                  .easy, // Will be handled as mixed
                              questionCount: questionCounts['total'] ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        child: _buildBottomBannerAd(),
      ),
    );
  }

  Widget _buildBottomBannerAd() {
    final bannerAd = _adMobService.getBottomBannerAd();

    if (bannerAd == null) {
      return const AdLoadingPlaceholder(
        height: 60,
        message: 'Ad Loading...',
        showSpinner: false,
      );
    }

    return bannerAd;
  }
}
