// model/services/OtpService.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pim_project/constants/constants.dart';

class OtpService {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${AppConstants.baseUrl}/account'));


  // Send OTP request via Email
  Future<bool> sendOtpEmail(String email) async {
    final Uri url = Uri.parse('${AppConstants.baseUrl}/account/forgot-password-otp-email');

    try {
      print("Sending OTP to: $email");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("OTP sent successfully!");
        return true;
      } else {
        print("Failed to send OTP: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

  // Verify OTP request
  Future<bool> verifyOtp(String otp, String userId) async {
    final Uri url = Uri.parse('${AppConstants.baseUrl}/account/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'otp': otp, 'userId': userId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("OTP verified successfully!");
        return true;
      } else {
        print("Invalid or expired OTP");
        return false;
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

 Future<bool> resetPassword(String userId, String newPassword, String confirmPassword) async {
  try {
    final response = await _dio.post(
      '/reset-password',  // Make sure the URL is correct
      data: {
        'userId': userId,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    print("Error resetting password: ${e.toString()}");
    return false;
  }
}

}
