import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../providers/auth_provider.dart";
import "../../services/admob_service.dart";
import "../../services/wallet_service.dart";
import "../../constants/app_constants.dart";
import "../quiz/quiz_category_screen.dart";
import "settings_screen.dart";
import "backend_status_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).userData;
    final walletService = Provider.of<WalletService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with User Info
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Welcome back!',
                style: AppTextStyles.headline3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => _navigateToSettings(),
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Stats Card
                  if (user != null) ...[
                    _buildUserStatsCard(user, walletService),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions Section
                  _buildSectionHeader('Quick Actions', Icons.flash_on),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(),

                  const SizedBox(height: 24),

                  // Featured Quizzes Section
                  _buildSectionHeader('Featured Quizzes', Icons.star),
                  const SizedBox(height: 16),
                  _buildFeaturedQuizzes(),

                  const SizedBox(height: 24),

                  // Recent Activity Section
                  _buildSectionHeader('Recent Activity', Icons.history),
                  const SizedBox(height: 16),
                  _buildRecentActivity(),

                  const SizedBox(height: 24),

                  // Backend Test Section
                  _buildSectionHeader('Backend Test', Icons.cloud),
                  const SizedBox(height: 16),
                  _buildBackendTestSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // Banner Ad at bottom
      bottomNavigationBar: _buildBannerAd(),
    );
  }

  Widget _buildUserStatsCard(user, WalletService walletService) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : user.email[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : 'Quiz Learner',
                    style: AppTextStyles.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${walletService.coins} Coins',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          "Start Quiz",
          "Take a new quiz",
          Icons.quiz,
          AppColors.primary,
          () => _navigateToQuizCategory(),
        ),
        _buildActionCard(
          "Daily Login",
          "Claim daily rewards",
          Icons.calendar_today,
          AppColors.success,
          () => _showComingSoonDialog("Daily Login"),
        ),
        _buildActionCard(
          "Backend Status",
          "Monitor connection",
          Icons.cloud,
          AppColors.warning,
          () => _navigateToBackendStatus(),
        ),
        _buildActionCard(
          "Earn Coins",
          "Complete tasks",
          Icons.monetization_on,
          AppColors.success,
          () => _showComingSoonDialog("Coins Feature"),
        ),
      ],
    );
  }

  Widget _buildFeaturedQuizzes() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuizCard("Science", "Test your knowledge", Icons.science,
              AppColors.primary),
          _buildQuizCard("History", "Travel through time", Icons.history_edu,
              AppColors.secondary),
          _buildQuizCard(
              "Geography", "Explore the world", Icons.public, AppColors.info),
          _buildQuizCard("Mathematics", "Solve problems", Icons.calculate,
              AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildQuizCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _navigateToQuizCategory(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityItem(
              Icons.quiz,
              "Completed Science Quiz",
              "You scored 85% on Science Quiz",
              "2 hours ago",
              AppColors.success,
            ),
            const Divider(),
            _buildActivityItem(
              Icons.monetization_on,
              "Earned 50 Coins",
              "Quiz completion reward",
              "Yesterday",
              AppColors.warning,
            ),
            const Divider(),
            _buildActivityItem(
              Icons.people,
              "Referred a friend",
              "New referral bonus earned",
              "3 days ago",
              AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    final bannerAd = AdMobService.instance.getBottomBannerAd();

    if (bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      width: double.infinity,
      height: 50,
      child: bannerAd,
    );
  }

  // Navigation methods
  void _navigateToQuizCategory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuizCategoryScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToBackendStatus() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BackendStatusScreen(),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon!'),
        content: Text(
            'This feature is under development and will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendTestSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Backend Connection Test',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _testBackendConnection(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Backend Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testBackendConnection() async {
    // Import and use the backend test service
    // This will be implemented when we run the app
    _showComingSoonDialog('Backend Test');
  }
}
