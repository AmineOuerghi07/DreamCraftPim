// model/repositories/user_repository.dart
import 'dart:io';

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
  Future<ApiResponse<User>> googleLogin(String googleToken, String email, String fullname, String? photoUrl) async {
    try {
      print('🔐 [UserRepository] Début de la connexion Google');
      print('📧 Email: $email');
      print('👤 Nom: $fullname');
      print('🖼️ Image: $photoUrl');

      final response = await userService.googleLogin(googleToken, email, fullname, photoUrl);
      print('✅ [UserRepository] Réponse reçue du service');
      print('📊 Statut: ${response.status}');
      print('📄 Données: ${response.data?.toJson()}');

      return response;
    } catch (e) {
      print('❌ [UserRepository] Erreur lors de la connexion Google: $e');
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
  Future<ApiResponse<User>> updateUserProfile(
  String userId, 
  Map<String, dynamic> updates,
  File? imageFile,
) async {
  try {
    // If there's an image file, use the multipart update method
    if (imageFile != null) {
      return await userService.updateUserProfile(
        userId,
        Map<String, String>.from(updates.map((key, value) => 
          MapEntry(key, value.toString()))),
        imageFile,
      );
    }
    // Otherwise use the regular update method
    return await userService.updateUserProfile(
      userId,
      Map<String, String>.from(updates
          .map((key, value) => MapEntry(key, value.toString()))),
      null,
    );
  } catch (e) {
    return ApiResponse.error('Repository error updating profile: ${e.toString()}');
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
