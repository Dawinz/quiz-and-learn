import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/withdrawal_model.dart';
import '../../services/api_service.dart';
import 'withdrawal_history_screen.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  WithdrawalMethod _selectedMethod = WithdrawalMethod.mpesa;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.withdrawalRequest),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WithdrawalHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authProvider.userData!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
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
                        Text('Available Balance', style: AppTextStyles.body2),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          '${user.coins} coins',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Withdrawal Method
                  Text(AppStrings.selectMethod, style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.padding),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: DropdownButtonFormField<WithdrawalMethod>(
                      value: _selectedMethod,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: WithdrawalMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Row(
                            children: [
                              Icon(_getMethodIcon(method)),
                              const SizedBox(width: AppSizes.paddingSmall),
                              Text(
                                WithdrawalMethods.methods[
                                    method.toString().split('.').last]!,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMethod = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Account Input
                  TextFormField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      labelText: AppStrings.enterAccount,
                      prefixIcon: const Icon(Icons.account_circle),
                      hintText: WithdrawalMethods.placeholders[
                          _selectedMethod.toString().split('.').last],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your account details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: AppStrings.enterAmount,
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'coins',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = int.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount < 100) {
                        return 'Minimum withdrawal amount is 100 coins';
                      }
                      if (amount > user.coins) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Minimum Amount Info
                  Container(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: AppColors.info,
                          size: AppSizes.iconSizeSmall,
                        ),
                        const SizedBox(width: AppSizes.paddingSmall),
                        Expanded(
                          child: Text(
                            AppStrings.minimumAmount,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitWithdrawal,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppStrings.submitRequest),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getMethodIcon(WithdrawalMethod method) {
    switch (method) {
      case WithdrawalMethod.mpesa:
        return Icons.phone_android;
      case WithdrawalMethod.tigopesa:
        return Icons.phone_android;
      case WithdrawalMethod.airtel:
        return Icons.phone_android;
      case WithdrawalMethod.halopesa:
        return Icons.phone_android;
      case WithdrawalMethod.usdt:
        return Icons.account_balance_wallet;
    }
  }

  Future<void> _submitWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final amount = double.parse(_amountController.text);

        final apiService = ApiService();
        final response = await apiService.requestWithdrawal(
          amount: amount,
          method: _selectedMethod.name,
          accountDetails: _accountController.text.trim(),
        );

        if (response['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Withdrawal request submitted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception(response['error']);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting withdrawal: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
