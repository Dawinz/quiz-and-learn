import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/referral_service.dart';
import '../models/referral_models.dart';

class ReferralInputScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final VoidCallback? onReferralApplied;

  const ReferralInputScreen({
    Key? key,
    required this.userId,
    required this.userEmail,
    this.onReferralApplied,
  }) : super(key: key);

  @override
  State<ReferralInputScreen> createState() => _ReferralInputScreenState();
}

class _ReferralInputScreenState extends State<ReferralInputScreen> {
  final ReferralService _referralService = ReferralService();
  final TextEditingController _referralController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isValidating = false;
  bool _isApplying = false;
  String? _validationMessage;
  String? _referrerId;

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _validateReferralCode() async {
    final code = _referralController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter a referral code';
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });

    try {
      final response = await _referralService.validateReferralCode(code);

      if (response.success && response.isValid) {
        setState(() {
          _validationMessage = '✓ Valid referral code!';
          _referrerId = response.referrerId;
        });
      } else {
        setState(() {
          _validationMessage = 'Invalid referral code';
          _referrerId = null;
        });
      }
    } catch (e) {
      setState(() {
        _validationMessage = 'Error validating code: $e';
        _referrerId = null;
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  Future<void> _applyReferralCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_referrerId == null) return;

    setState(() {
      _isApplying = true;
    });

    try {
      final response = await _referralService.useReferralCode(
        _referralController.text.trim(),
        widget.userId,
        widget.userEmail,
      );

      if (response.success) {
        _showSuccessDialog(response);
        widget.onReferralApplied?.call();
      } else {
        _showErrorSnackBar(
            'Failed to apply referral code: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  void _showSuccessDialog(ReferralUsageResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Referral Applied!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Congratulations! You\'ve successfully applied a referral code.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Welcome Bonus',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${response.rewardAmount} coins',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your referral will receive ${response.rewardAmount} coins once you complete the onboarding process!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _skipReferral() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Referral?'),
        content: Text(
          'You can always add a referral code later from your profile settings. Are you sure you want to skip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Referral Code'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipReferral,
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 32),
              _buildReferralInput(),
              SizedBox(height: 24),
              _buildValidationMessage(),
              SizedBox(height: 32),
              _buildApplyButton(),
              SizedBox(height: 24),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.card_giftcard,
          size: 80,
          color: Colors.blue[600],
        ),
        SizedBox(height: 24),
        Text(
          'Have a Referral Code?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Enter a friend\'s referral code to get a welcome bonus and help them earn coins!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReferralInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Referral Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _referralController,
          decoration: InputDecoration(
            hintText: 'Enter referral code (e.g., ABC123DEF456)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
            ),
            suffixIcon: IconButton(
              onPressed: _isValidating ? null : _validateReferralCode,
              icon: _isValidating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.verified, color: Colors.blue[600]),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a referral code';
            }
            if (value.trim().length < 10) {
              return 'Referral code is too short';
            }
            return null;
          },
          onChanged: (value) {
            if (_validationMessage != null) {
              setState(() {
                _validationMessage = null;
                _referrerId = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildValidationMessage() {
    if (_validationMessage == null) return SizedBox.shrink();

    final isSuccess = _validationMessage!.startsWith('✓');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green[600] : Colors.red[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _validationMessage!,
              style: TextStyle(
                color: isSuccess ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    final canApply =
        _referrerId != null && _referralController.text.trim().isNotEmpty;

    return ElevatedButton(
      onPressed: canApply && !_isApplying ? _applyReferralCode : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isApplying
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Apply Referral Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: Colors.blue[600],
            ),
            SizedBox(height: 16),
            Text(
              'How Referrals Work',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.person_add,
              text: 'You get a welcome bonus when you use a referral code',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.monetization_on,
              text: 'Your friend earns 100 coins when you complete onboarding',
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.share,
              text: 'Share your own referral code to earn coins too!',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
