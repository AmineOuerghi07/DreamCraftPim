// model/repositories/user_repository.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/user_service.dart';

class UserRepository extends ChangeNotifier {
  final UserService userService;

  UserRepository({required this.userService});

  // Login
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      return await userService.login(email, password);
    } catch (e) {
      return ApiResponse.error('Repository error during login: $e');
    }
  }

  // Sign up
  Future<ApiResponse<User>> signUpUser(User user) async {
    try {
      return await userService.signupUser(user);
    } catch (e) {
      return ApiResponse.error('Repository error during signup: $e');
    }
  }

  // Send OTP via email
  Future<ApiResponse<bool>> sendOtpByEmail(String email) async {
    try {
      return await userService.sendOtpEmail(email);
    } catch (e) {
      return ApiResponse.error('Repository error sending OTP: $e');
    }
  }

  // Google login
  Future<ApiResponse<User>> googleLogin(String googleToken) async {
    try {
      return await userService.googleLogin(googleToken);
    } catch (e) {
      return ApiResponse.error('Repository error during Google login: $e');
    }
  }

  // Get user profile
  Future<ApiResponse<User>> getUserProfile(String userId) async {
    try {
      return await userService.getUserProfile(userId);
    } catch (e) {
      return ApiResponse.error('Repository error fetching profile: $e');
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      return await userService.updateUserProfile(userId, updates);
    } catch (e) {
      return ApiResponse.error('Repository error updating profile: $e');
    }
  }

  // Reset password
  Future<ApiResponse<bool>> resetPassword(String userId, String newPassword, String confirmPassword) async {
    try {
      return await userService.resetPassword(userId, newPassword, confirmPassword);
    } catch (e) {
      return ApiResponse.error('Repository error resetting password: $e');
    }
  }

  // Verify OTP
  Future<ApiResponse<bool>> verifyOtp(String otp, String userId) async {
    try {
      return await userService.verifyOtp(otp, userId);
    } catch (e) {
      return ApiResponse.error('Repository error verifying OTP: $e');
    }
  }
}
