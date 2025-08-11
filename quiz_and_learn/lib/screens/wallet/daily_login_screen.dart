import 'package:flutter/material.dart';
import '../../services/enhanced_wallet_service.dart';
import '../../constants/app_constants.dart';

class DailyLoginScreen extends StatefulWidget {
  const DailyLoginScreen({super.key});

  @override
  State<DailyLoginScreen> createState() => _DailyLoginScreenState();
}

class _DailyLoginScreenState extends State<DailyLoginScreen> {
  final EnhancedWalletService _walletService = EnhancedWalletService.instance;
  bool _isLoading = true;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _loadDailyLoginData();
  }

  Future<void> _loadDailyLoginData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _walletService.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading daily login data: $e');
    }
  }

  Future<void> _claimDailyLoginBonus() async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final success = await _walletService.claimDailyLoginBonus();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily login bonus claimed! You earned ${_walletService.dailyLoginStreak * 5 + 10} coins.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data
        _loadDailyLoginData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already claimed your daily login bonus today.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error claiming daily login bonus. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isClaiming = false;
      });
    }
  }

  String _formatTimeUntilNext(Duration? duration) {
    if (duration == null || duration.inSeconds <= 0) return 'Available now!';
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canClaim = _walletService.canClaimDailyLoginBonus;
    final timeUntilNext = _walletService.timeUntilNextDailyLogin;
    final currentStreak = _walletService.dailyLoginStreak;
    final lastLogin = _walletService.lastDailyLogin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Login Bonus'),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Main Bonus Card
                  _buildMainBonusCard(canClaim, currentStreak),
                  
                  const SizedBox(height: 24),
                  
                  // Streak Information
                  _buildStreakCard(currentStreak),
                  
                  const SizedBox(height: 24),
                  
                  // Weekly Calendar
                  _buildWeeklyCalendar(lastLogin),
                  
                  const SizedBox(height: 24),
                  
                  // Bonus Schedule
                  _buildBonusSchedule(),
                  
                  const SizedBox(height: 24),
                  
                  // Last Login Info
                  if (lastLogin != null) _buildLastLoginInfo(lastLogin),
                ],
              ),
            ),
    );
  }

  Widget _buildMainBonusCard(bool canClaim, int currentStreak) {
    final bonusAmount = currentStreak * 5 + 10; // Base 10 + streak bonus
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canClaim 
              ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
              : [Colors.grey, Colors.grey.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (canClaim ? AppColors.primary : Colors.grey).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canClaim ? Icons.card_giftcard : Icons.schedule,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                canClaim ? 'Claim Your Bonus!' : 'Bonus Available Soon',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bonus Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Today\'s Bonus',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$bonusAmount coins',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Claim Button or Timer
          if (canClaim)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isClaiming ? null : _claimDailyLoginBonus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isClaiming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : const Text(
                        'Claim Bonus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Next bonus available in:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeUntilNext(_walletService.timeUntilNextDailyLogin),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Streak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  'Current',
                  '$currentStreak days',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStreakStat(
                  'Base Bonus',
                  '10 coins',
                  Icons.star,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStreakStat(
                  'Streak Bonus',
                  '${currentStreak * 5} coins',
                  Icons.flash_on,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Streak Progress
          if (currentStreak > 0) ...[
            const Text(
              'Keep your streak alive!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentStreak % 7) / 7, // Progress within week
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value, IconData icon, Color color) {
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
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(DateTime? lastLogin) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'This Week\'s Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final hasLogin = lastLogin != null && 
                  date.year == lastLogin.year &&
                  date.month == lastLogin.month &&
                  date.day == lastLogin.day;
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasLogin 
                            ? AppColors.primary 
                            : isToday 
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        border: isToday 
                            ? Border.all(color: Colors.orange, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: hasLogin
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : isToday
                                ? Text(
                                    '${now.day}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  )
                                : Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildBonusSchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Bonus Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildBonusRow(1, 3, '10 coins'),
          _buildBonusRow(4, 7, '25 coins'),
          _buildBonusRow(8, 14, '40 coins'),
          _buildBonusRow(15, 30, '60 coins'),
          _buildBonusRow(31, 60, '80 coins'),
          _buildBonusRow(61, 100, '100 coins'),
          _buildBonusRow(101, null, '150 coins'),
        ],
      ),
    );
  }

  Widget _buildBonusRow(int startDay, int? endDay, String bonus) {
    final range = endDay != null ? '$startDay-$endDay days' : '$startDay+ days';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              range,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Daily bonus: $bonus',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onBackground,
              ),
            ),
          ),
          Text(
            bonus,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastLoginInfo(DateTime lastLogin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Last Login Info',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Last Login',
                  _formatDate(lastLogin),
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Time Ago',
                  _formatTimeAgo(lastLogin),
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
