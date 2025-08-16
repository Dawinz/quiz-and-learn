import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class BackendTestService {
  final ConfigService _configService = ConfigService();
  
  // Test backend connection
  Future<bool> testConnection() async {
    try {
      await _configService.initialize();
      final response = await http.get(
        Uri.parse('${_configService.fullApiUrl}/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend connection successful: ${data['message']}');
        return true;
      } else {
        print('❌ Backend connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Backend connection error: $e');
      return false;
    }
  }
  
  // Add sample user
  Future<bool> addSampleUser(String name, String email, String password) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Sample user added: $name');
        return true;
      } else {
        print('❌ Failed to add sample user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding sample user: $e');
      return false;
    }
  }
  
  // Generate referral code for user
  Future<String?> generateReferralCode(String userId, String userEmail) async {
    try {
      await _configService.initialize();
      final response = await http.post(
        Uri.parse('${_configService.fullApiUrl}/referral'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'generate',
          'userId': userId,
          'userEmail': userEmail,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Referral code generated: ${data['referralCode']}');
        return data['referralCode'];
      } else {
        print('❌ Failed to generate referral code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error generating referral code: $e');
      return null;
    }
  }
  
  // Test referral system
  Future<void> testReferralSystem() async {
    print('🧪 Testing referral system...');
    
    // Test connection first
    if (!await testConnection()) {
      print('❌ Cannot test referral system - backend not accessible');
      return;
    }
    
    // Add sample users
    final users = [
      {'name': 'John QuizMaster', 'email': 'john@quizlearn.com', 'password': 'password123'},
      {'name': 'Sarah Brainiac', 'email': 'sarah@quizlearn.com', 'password': 'password123'},
      {'name': 'Mike Knowledge', 'email': 'mike@quizlearn.com', 'password': 'password123'},
    ];
    
    for (final user in users) {
      final success = await addSampleUser(user['name']!, user['email']!, user['password']!);
      if (success) {
        // Generate referral code (using email as userId for demo)
        await generateReferralCode(user['email']!, user['email']!);
      }
    }
    
    print('✅ Referral system test completed!');
  }
}
