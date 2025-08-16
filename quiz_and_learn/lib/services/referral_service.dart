import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/referral_models.dart';
import 'config_service.dart';

class ReferralService {
  final ConfigService _configService = ConfigService();
  
  // Generate referral code for current user
  Future<ReferralCodeResponse> generateReferralCode(String userId, String userEmail) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/referral'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'generate',
          'userId': userId,
          'userEmail': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReferralCodeResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to generate referral code');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Use referral code during signup
  Future<ReferralUsageResponse> useReferralCode(String referralCode, String userId, String userEmail) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/referral'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'use',
          'referralCode': referralCode,
          'userId': userId,
          'userEmail': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReferralUsageResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to use referral code');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Validate referral code before using
  Future<ReferralValidationResponse> validateReferralCode(String referralCode) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/referral'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'validate',
          'referralCode': referralCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReferralValidationResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to validate referral code');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user's referral information and history
  Future<ReferralInfoResponse> getReferralInfo(String userId) async {
    try {
      await _configService.initialize();
      final response = await http.get(
        Uri.parse('${_configService.fullApiUrl}/referral?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReferralInfoResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to get referral info');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Process referral reward when user completes onboarding
  Future<bool> processReferralReward(String referredUserId) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/reward-processor'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'complete-onboarding',
          'userId': referredUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
