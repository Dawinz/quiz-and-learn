import 'package:flutter/material.dart';
import '../../models/premium_feature.dart';
import '../../services/enhanced_wallet_service.dart';
import '../../constants/app_constants.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> {
  final EnhancedWalletService _walletService = EnhancedWalletService.instance;
  List<PremiumFeature> _availableFeatures = [];
  List<UserPremiumFeature> _userFeatures = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadPremiumFeatures();
  }

  Future<void> _loadPremiumFeatures() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _walletService.initialize();

      // For now, create sample data
      await Future.delayed(const Duration(seconds: 1));

      _availableFeatures = _getSampleFeatures();
      _userFeatures = _getSampleUserFeatures();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading premium features: $e');
    }
  }

  List<PremiumFeature> _getSampleFeatures() {
    return [
      PremiumFeature(
        id: 'ad_removal_7d',
        name: 'Ad Removal (7 Days)',
        description: 'Remove all ads from the app for 7 days',
        type: FeatureType.adRemoval,
        coinCost: 200,
        duration: const Duration(days: 7),
        iconPath: 'assets/icons/ad_removal.png',
      ),
      PremiumFeature(
        id: 'ad_removal_30d',
        name: 'Ad Removal (30 Days)',
        description: 'Remove all ads from the app for 30 days',
        type: FeatureType.adRemoval,
        coinCost: 500,
        duration: const Duration(days: 30),
        iconPath: 'assets/icons/ad_removal.png',
      ),
      PremiumFeature(
        id: 'premium_quizzes',
        name: 'Premium Quizzes',
        description: 'Access exclusive premium quiz content',
        type: FeatureType.premiumQuiz,
        coinCost: 300,
        iconPath: 'assets/icons/premium_quiz.png',
      ),
      PremiumFeature(
        id: 'unlimited_quizzes',
        name: 'Unlimited Quizzes',
        description: 'Remove daily quiz limits for 7 days',
        type: FeatureType.unlimitedQuizzes,
        coinCost: 150,
        duration: const Duration(days: 7),
        iconPath: 'assets/icons/unlimited.png',
      ),
      PremiumFeature(
        id: 'advanced_analytics',
        name: 'Advanced Analytics',
        description: 'Get detailed performance insights and statistics',
        type: FeatureType.advancedAnalytics,
        coinCost: 400,
        iconPath: 'assets/icons/analytics.png',
      ),
      PremiumFeature(
        id: 'custom_themes',
        name: 'Custom Themes',
        description: 'Unlock exclusive app themes and customization options',
        type: FeatureType.customThemes,
        coinCost: 250,
        iconPath: 'assets/icons/themes.png',
      ),
      PremiumFeature(
        id: 'priority_support',
        name: 'Priority Support',
        description: 'Get faster customer support response times',
        type: FeatureType.prioritySupport,
        coinCost: 600,
        iconPath: 'assets/icons/support.png',
      ),
    ];
  }

  List<UserPremiumFeature> _getSampleUserFeatures() {
    final now = DateTime.now();
    return [
      UserPremiumFeature(
        id: '1',
        userId: 'user1',
        featureId: 'ad_removal_7d',
        status: FeatureStatus.unlocked,
        unlockedAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.add(const Duration(days: 5)),
        coinCost: 200,
      ),
      UserPremiumFeature(
        id: '2',
        userId: 'user1',
        featureId: 'premium_quizzes',
        status: FeatureStatus.unlocked,
        unlockedAt: now.subtract(const Duration(days: 10)),
        coinCost: 300,
      ),
    ];
  }

  List<PremiumFeature> _getFilteredFeatures() {
    if (_selectedCategory == 'all') {
      return _availableFeatures;
    }
    return _availableFeatures
        .where((f) => f.category == _selectedCategory)
        .toList();
  }

  bool _isFeatureUnlocked(String featureId) {
    return _userFeatures.any((f) => f.featureId == featureId && f.isActive);
  }

  UserPremiumFeature? _getUserFeature(String featureId) {
    try {
      return _userFeatures.firstWhere((f) => f.featureId == featureId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _unlockFeature(PremiumFeature feature) async {
    try {
      final success = await _walletService.unlockPremiumFeature(feature);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unlocked ${feature.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data
        _loadPremiumFeatures();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient coins to unlock this feature.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error unlocking feature. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFeatureDetails(PremiumFeature feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(feature.featureIcon),
            const SizedBox(width: 8),
            Expanded(child: Text(feature.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${feature.formattedDuration}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Category: ${feature.category}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!_isFeatureUnlocked(feature.id))
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unlockFeature(feature);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Unlock (${feature.coinCost} coins)'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFeatures = _getFilteredFeatures();
    final userBalance = _walletService.coins;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Premium Features'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Column(
              children: [
                // Balance Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Your Balance:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$userBalance coins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'All'),
                            _buildFilterChip('Quiz Features', 'Quiz Features'),
                            _buildFilterChip(
                                'User Experience', 'User Experience'),
                            _buildFilterChip(
                                'Premium Services', 'Premium Services'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Features List
                Expanded(
                  child: filteredFeatures.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredFeatures.length,
                          itemBuilder: (context, index) {
                            final feature = filteredFeatures[index];
                            return _buildFeatureCard(feature);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.onBackground,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.withOpacity(0.1),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    final isUnlocked = _isFeatureUnlocked(feature.id);
    final userFeature = _getUserFeature(feature.id);
    final canAfford = _walletService.coins >= feature.coinCost;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUnlocked
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showFeatureDetails(feature),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: isUnlocked
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Feature Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        feature.featureIcon,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Feature Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? AppColors.primary
                                : AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Feature Details
              Row(
                children: [
                  // Duration
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        feature.formattedDuration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Category
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        feature.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Price or Status
                  if (isUnlocked && userFeature != null)
                    Text(
                      userFeature.expiryStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            userFeature.isExpired ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${feature.coinCost} coins',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              // Action Button
              if (!isUnlocked) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford ? () => _unlockFeature(feature) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canAfford ? AppColors.primary : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      canAfford ? 'Unlock Feature' : 'Insufficient Coins',
                    ),
                  ),
                ),
              ],
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
            Icons.star_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No features found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your category filter or check back later for new features!',
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
}
