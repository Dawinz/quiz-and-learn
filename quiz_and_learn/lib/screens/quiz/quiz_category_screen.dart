import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/quiz_question.dart';
import '../../services/admob_service.dart';
import '../../widgets/ad_loading_overlay.dart';
import '../../widgets/ad_loading_status.dart';
import 'quiz_difficulty_screen.dart';

class QuizCategoryScreen extends StatefulWidget {
  const QuizCategoryScreen({super.key});

  @override
  State<QuizCategoryScreen> createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
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

  void _navigateToDifficulty(QuizCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizDifficultyScreen(category: category),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required QuizCategory category,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _navigateToDifficulty(category),
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
                  'Tap to Start',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quiz Categories'),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Quiz Category',
                    style: AppTextStyles.headline2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a category and difficulty level to start learning!',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.onBackground.withAlpha(179),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    children: [
                      _buildCategoryCard(
                        icon: Icons.public,
                        color: Colors.blue,
                        title: 'General Knowledge',
                        description: 'Test your knowledge on various topics',
                        category: QuizCategory.general,
                      ),
                      _buildCategoryCard(
                        icon: Icons.science,
                        color: Colors.green,
                        title: 'Science',
                        description: 'Explore the world of science',
                        category: QuizCategory.science,
                      ),
                      _buildCategoryCard(
                        icon: Icons.history_edu,
                        color: Colors.orange,
                        title: 'History',
                        description: 'Journey through time and events',
                        category: QuizCategory.history,
                      ),
                      _buildCategoryCard(
                        icon: Icons.public,
                        color: Colors.purple,
                        title: 'Geography',
                        description: 'Discover the world around us',
                        category: QuizCategory.geography,
                      ),
                      _buildCategoryCard(
                        icon: Icons.calculate,
                        color: Colors.red,
                        title: 'Mathematics',
                        description: 'Solve mathematical challenges',
                        category: QuizCategory.mathematics,
                      ),
                      _buildCategoryCard(
                        icon: Icons.book,
                        color: Colors.indigo,
                        title: 'Literature',
                        description: 'Explore great works of literature',
                        category: QuizCategory.literature,
                      ),
                      _buildCategoryCard(
                        icon: Icons.computer,
                        color: Colors.teal,
                        title: 'Technology',
                        description: 'Learn about modern technology',
                        category: QuizCategory.technology,
                      ),
                      _buildCategoryCard(
                        icon: Icons.sports_soccer,
                        color: Colors.amber,
                        title: 'Sports',
                        description: 'Test your sports knowledge',
                        category: QuizCategory.sports,
                      ),
                      _buildCategoryCard(
                        icon: Icons.movie,
                        color: Colors.pink,
                        title: 'Entertainment',
                        description: 'Movies, music, and pop culture',
                        category: QuizCategory.entertainment,
                      ),
                      _buildCategoryCard(
                        icon: Icons.favorite,
                        color: Colors.red,
                        title: 'Health',
                        description: 'Learn about health and wellness',
                        category: QuizCategory.health,
                      ),
                      _buildCategoryCard(
                        icon: Icons.eco,
                        color: Colors.lightGreen,
                        title: 'Environment',
                        description: 'Understand our planet',
                        category: QuizCategory.environment,
                      ),
                      _buildCategoryCard(
                        icon: Icons.attach_money,
                        color: Colors.green,
                        title: 'Economics',
                        description: 'Learn about money and economy',
                        category: QuizCategory.economics,
                      ),
                      _buildCategoryCard(
                        icon: Icons.gavel,
                        color: Colors.grey,
                        title: 'Politics',
                        description: 'Understand government and politics',
                        category: QuizCategory.politics,
                      ),
                      _buildCategoryCard(
                        icon: Icons.palette,
                        color: Colors.deepPurple,
                        title: 'Art',
                        description: 'Explore creativity and expression',
                        category: QuizCategory.art,
                      ),
                      _buildCategoryCard(
                        icon: Icons.music_note,
                        color: Colors.deepOrange,
                        title: 'Music',
                        description: 'Discover the world of music',
                        category: QuizCategory.music,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
