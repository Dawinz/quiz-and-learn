import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_preferences_service.dart';
import '../../models/user_preferences.dart';
import '../referral_code_screen.dart';
import '../referral_input_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _userPreferencesService = UserPreferencesService();

  String _selectedAvatar = '';
  bool _isLoading = false;
  UserPreferences? _currentPreferences;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    setState(() => _isLoading = true);

    try {
      // Initialize with a default user ID (you can get this from auth service)
      await _userPreferencesService.initialize('default_user');
      _currentPreferences = _userPreferencesService.currentPreferences;

      if (_currentPreferences != null) {
        _displayNameController.text = _currentPreferences!.displayName;
        _selectedAvatar = _currentPreferences!.avatarUrl;
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _userPreferencesService.setDisplayName(_displayNameController.text);
      await _userPreferencesService.setAvatar(_selectedAvatar);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectAvatar(String avatarUrl) {
    setState(() {
      _selectedAvatar = avatarUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(theme),
                    const SizedBox(height: 32),

                    // Display Name Section
                    _buildDisplayNameSection(theme),
                    const SizedBox(height: 32),

                    // Save Button
                    _buildSaveButton(theme),
                    const SizedBox(height: 24),

                    // Referral Section
                    _buildReferralSection(theme),

                    const SizedBox(height: 24),

                    // Avatar Selection Section
                    _buildAvatarSelectionSection(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Current Profile Picture
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: _selectedAvatar.isNotEmpty
                    ? NetworkImage(_selectedAvatar)
                    : null,
                child: _selectedAvatar.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Avatar Selection Grid
        Text(
          'Choose Avatar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _getAvatarOptions().length,
          itemBuilder: (context, index) {
            final avatar = _getAvatarOptions()[index];
            final isSelected = _selectedAvatar == avatar;

            return GestureDetector(
              onTap: () => _selectAvatar(avatar),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: NetworkImage(avatar),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDisplayNameSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Name',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _displayNameController,
          decoration: InputDecoration(
            labelText: 'Enter your display name',
            hintText: 'e.g., Quiz Master',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Display name is required';
            }
            if (value.trim().length < 2) {
              return 'Display name must be at least 2 characters';
            }
            if (value.trim().length > 30) {
              return 'Display name must be less than 30 characters';
            }
            return null;
          },
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save Profile',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildReferralSection(ThemeData theme) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userData;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Referral Program',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Invite friends and earn coins together!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (user != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReferralCodeScreen(
                              userId: user.id,
                              userEmail: user.email,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('My Referral Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (user != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReferralInputScreen(
                              userId: user.id,
                              userEmail: user.email,
                              onReferralApplied: () {
                                // Refresh user data after referral is applied
                                authProvider.updateUserProfile({});
                              },
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.input, size: 18),
                    label: const Text('Add Referral'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (user?.referralCount != null && user!.referralCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'You have ${user.referralCount} referral${user.referralCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelectionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Avatar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _getAvatarOptions().length,
          itemBuilder: (context, index) {
            final avatar = _getAvatarOptions()[index];
            final isSelected = _selectedAvatar == avatar;

            return GestureDetector(
              onTap: () => _selectAvatar(avatar),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: NetworkImage(avatar),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> _getAvatarOptions() {
    // You can replace these with actual avatar URLs from your backend
    return [
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Jasper',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Luna',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Max',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Zoe',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Kai',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Aria',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Leo',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Maya',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Finn',
      'https://api.dicebear.com/7.x/avataaars/svg?seed=Isla',
    ];
  }
}
