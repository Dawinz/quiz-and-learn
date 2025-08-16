import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userData;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  AppColors.onPrimary.withOpacity(0.2),
                              backgroundImage: user.profilePicture != null
                                  ? NetworkImage(user.profilePicture!)
                                  : null,
                              child: user.profilePicture == null
                                  ? Text(
                                      user.name.substring(0, 1).toUpperCase(),
                                      style: AppTextStyles.headline1.copyWith(
                                        color: AppColors.onPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: AppSizes.spacingMedium),
                            Text(
                              user.name,
                              style: AppTextStyles.headline2.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingSmall),
                            Text(
                              user.email,
                              style: AppTextStyles.body1.copyWith(
                                color: AppColors.onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Profile Options
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    children: [
                      _buildProfileSection(
                        title: 'Account',
                        items: [
                          _buildProfileItem(
                            icon: Icons.person,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            onTap: () {
                              // Navigate to edit profile
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.security,
                            title: 'Security',
                            subtitle: 'Change password and security settings',
                            onTap: () {
                              // Navigate to security
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.privacy_tip,
                            title: 'Privacy',
                            subtitle: 'Manage your privacy settings',
                            onTap: () {
                              // Navigate to privacy
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacingLarge),

                      _buildProfileSection(
                        title: 'Preferences',
                        items: [
                          _buildProfileItem(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            subtitle: 'Manage notification preferences',
                            onTap: () {
                              // Navigate to notifications
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.language,
                            title: 'Language',
                            subtitle: 'Change app language',
                            onTap: () {
                              // Navigate to language settings
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.dark_mode,
                            title: 'Theme',
                            subtitle: 'Choose your preferred theme',
                            onTap: () {
                              // Navigate to theme settings
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacingLarge),

                      _buildProfileSection(
                        title: 'Support',
                        items: [
                          _buildProfileItem(
                            icon: Icons.help,
                            title: 'Help Center',
                            subtitle: 'Get help and support',
                            onTap: () {
                              // Navigate to help center
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.feedback,
                            title: 'Send Feedback',
                            subtitle: 'Share your thoughts with us',
                            onTap: () {
                              // Navigate to feedback
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.info,
                            title: 'About',
                            subtitle: 'App version and information',
                            onTap: () {
                              // Navigate to about
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spacingLarge),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                    'Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.onPrimary,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await authProvider.signOut();
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.padding),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radius),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacingLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMedium),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
