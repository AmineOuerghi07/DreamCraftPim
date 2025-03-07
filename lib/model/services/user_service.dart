// model/services/user_service.dart
import 'package:dio/dio.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/constants/constants.dart';

class UserService {
  final ApiClient _apiClient;
  
  UserService({required ApiClient apiClient}) : _apiClient = apiClient;

  // Login user
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        'account/sign-in',
        {'email': email, 'password': password},
        (json) => User.fromJson(json),
      );

      if (response.status == Status.COMPLETED && response.data != null) {
        // Store userId in preferences
        await UserPreferences.setUserId(response.data!.userId);
        MyApp.userId = response.data!.userId;
      }

      return response;
    } catch (e) {
      return ApiResponse.error('Error during login: $e');
    }
  }

  // Sign up user
  Future<ApiResponse<User>> signupUser(User user) async {
    try {
      return await _apiClient.post(
        'account/sign-up',
        user.toJson(),
        (json) => User.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error('Error during signup: $e');
    }
  }

  // Send OTP via email
  Future<ApiResponse<bool>> sendOtpEmail(String email) async {
    try {
      final response = await _apiClient.post(
        'account/forgot-password-otp-email',
        {'email': email},
        (json) => true,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Error sending OTP: $e');
    }
  }

  // Google login
  Future<ApiResponse<User>> googleLogin(String googleToken) async {
    try {
      return await _apiClient.post(
        'account/google-login',
        {'google_token': googleToken},
        (json) => User.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error('Error during Google login: $e');
    }
  }

  // Get user profile
  Future<ApiResponse<User>> getUserProfile(String userId) async {
    try {
      return await _apiClient.get(
        'account/profile/$userId',
        (json) => User.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      return await _apiClient.put(
        'account/profile/$userId',
        updates,
        (json) => User.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error('Error updating user profile: $e');
    }
  }

  // Reset password
  Future<ApiResponse<bool>> resetPassword(String userId, String newPassword, String confirmPassword) async {
    try {
      final response = await _apiClient.post(
        'account/reset-password',
        {
          'userId': userId,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        (json) => true,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Error resetting password: $e');
    }
  }

  // Verify OTP
  Future<ApiResponse<bool>> verifyOtp(String otp, String userId) async {
    try {
      final response = await _apiClient.post(
        'account/verify-otp',
        {'otp': otp, 'userId': userId},
        (json) => true,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Error verifying OTP: $e');
    }
  }
}
