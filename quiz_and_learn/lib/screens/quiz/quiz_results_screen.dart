import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/admob_service.dart';

import '../../widgets/ad_loading_overlay.dart';

class QuizResultsScreen extends StatefulWidget {
  final String category;
  final int score;
  final int totalQuestions;

  const QuizResultsScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  final AdMobService _adMobService = AdMobService.instance;
  bool _isRewardedAdLoading = false;
  bool _hasShownRewardedAd = false;
  bool _isInterstitialAdLoading = false;


  @override
  void initState() {
    super.initState();
    // Show interstitial ad when results screen opens
    _showInterstitialAd();
  }

  Future<void> _showInterstitialAd() async {
    setState(() {
      _isInterstitialAdLoading = true;
    });

    try {
      if (_adMobService.isInitialized) {
        await _adMobService.showInterstitialBetweenLevels();
      }
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
    } finally {
      setState(() {
        _isInterstitialAdLoading = false;
      });
    }
  }

  Future<void> _showRewardedAd() async {
    if (_hasShownRewardedAd) {
      _showAlreadyWatchedMessage();
      return;
    }

    setState(() {
      _isRewardedAdLoading = true;
    });

    try {
      if (!_adMobService.isInitialized) {
        await _adMobService.initialize();
      }

      final success = await _adMobService.showRewardedAdForCoins();
      
      if (success) {
        setState(() {
          _hasShownRewardedAd = true;
        });
        _showRewardEarnedDialog();
      }
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
    } finally {
      setState(() {
        _isRewardedAdLoading = false;
      });
    }
  }

  void _showRewardEarnedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Bonus Coins Earned!'),
        content: const Text('You\'ve earned 10 bonus coins for watching the ad!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyWatchedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You\'ve already watched a rewarded ad for this quiz!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    final grade = _getGrade(percentage);
    final message = _getPerformanceMessage(percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Results Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Quiz Completed!',
                          style: AppTextStyles.headline1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Score: ${widget.score}/${widget.totalQuestions}',
                          style: AppTextStyles.headline2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grade: $grade',
                          style: AppTextStyles.headline3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Native Ad Section
                  _buildNativeAdSection(),

                  const SizedBox(height: 24),

                  // Rewarded Ad Prompt
                  _buildRewardedAdPrompt(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),

          // Bottom Banner Ad
          _buildBottomBannerAd(),
        ],
      ),
    );
  }

  Widget _buildNativeAdSection() {
    final nativeAd = _adMobService.getResultsScreenNativeAd();
    
    if (nativeAd == null) {
      return const AdLoadingOverlay(
        message: 'Loading Sponsored Content...',
        showSpinner: true,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsored Content',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: nativeAd),
        ],
      ),
    );
  }

  Widget _buildRewardedAdPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange[100]!,
            Colors.orange[200]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.monetization_on,
            size: 48,
            color: Colors.orange[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Earn Bonus Coins!',
            style: AppTextStyles.headline3.copyWith(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch a short video to earn 10 bonus coins!',
            style: AppTextStyles.body1.copyWith(
              color: Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AdLoadingButton(
            onPressed: _showRewardedAd,
            isLoading: _isRewardedAdLoading,
            loadingText: 'Loading Ad...',
            normalText: 'Watch Ad & Earn Coins',
            icon: Icons.play_arrow,
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Take Another Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Categories',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBannerAd() {
    final bannerAd = _adMobService.getBottomBannerAd();
    
    if (bannerAd == null) {
      return const AdLoadingPlaceholder(
        height: 50,
        message: 'Ad Loading...',
        showSpinner: false,
      );
    }

    return Container(
      width: double.infinity,
      height: 50,
      child: bannerAd,
    );
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  String _getPerformanceMessage(double percentage) {
    if (percentage >= 90) return 'Excellent! Outstanding performance!';
    if (percentage >= 80) return 'Great job! Well done!';
    if (percentage >= 70) return 'Good work! Keep it up!';
    if (percentage >= 60) return 'Not bad! You passed!';
    if (percentage >= 50) return 'Almost there! Study a bit more.';
    return 'Keep studying! You can do better next time.';
  }
}
