// model/services/user_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/UserPreferences.dart';
import 'package:pim_project/model/services/api_client.dart';

class UserService {
  final ApiClient _apiClient;
  
  UserService({required ApiClient apiClient}) : _apiClient = apiClient;



  // Login user
  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final loginResponse = await _apiClient.post(
        'account/sign-in',
        {'email': email, 'password': password},
        (json) => json,
      );

      if (loginResponse.status == Status.COMPLETED && loginResponse.data != null) {
        final token = loginResponse.data['token'] as String?;
        if (token == null) {
          return ApiResponse.error('No token received from server');
        }

        // Extract user ID from token
        try {
          final parts = token.split('.');
          if (parts.length != 3) {
            return ApiResponse.error('Invalid token format');
          }

          // Decode the payload
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final tokenData = jsonDecode(decoded);

          final userId = tokenData['id'];
          if (userId == null) {
            return ApiResponse.error('No user ID in token');
          }

          // Store token and user ID first
          await UserPreferences.setToken(token);
          await UserPreferences.setUserId(userId);
          MyApp.userId = userId;

          // Set the token for subsequent requests
          _apiClient.setAuthToken(token);

          // Now fetch the complete user profile using the correct endpoint
          print('Fetching complete profile for user: $userId');
          final profileResponse = await _apiClient.get(
            'account/get-account/$userId',
            (json) {
              print('Profile Response: $json');
              return User.fromJson(json);
            },
          );

          if (profileResponse.status == Status.COMPLETED && profileResponse.data != null) {
            // Store the complete user data
            await UserPreferences.setUser(profileResponse.data!);
            return profileResponse;
          } else {
            print('Failed to fetch profile. Status: ${profileResponse.status}, Message: ${profileResponse.message}');
            // If we can't get the full profile, create a minimal user object
            final minimalUser = User(
              userId: userId,
              email: tokenData['email'] ?? '',
              fullname: '',
              phonenumber: '',
              address: '',
              password: '',
              role: '',
              phone: ''
            );
            await UserPreferences.setUser(minimalUser);
            return ApiResponse.completed(minimalUser);
          }
        } catch (e) {
          print('Error processing login response: $e');
          return ApiResponse.error('Failed to process login response');
        }
      }

      return ApiResponse.error(loginResponse.message ?? 'Login failed');
    } catch (e) {
      print('Login Error: $e');
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
  }  // Get user profile
  Future<ApiResponse<User>> getUserProfile(String userId) async {
    try {
      // Get stored user data
      final user = await UserPreferences.getUser();
      if (user != null) {
        return ApiResponse.completed(user);
      }
      
      // If no stored user data, try to get token and decode it
      final token = await UserPreferences.getToken();
      if (token == null) {
        return ApiResponse.error('No authentication token found');
      }

      try {
        final parts = token.split('.');
        if (parts.length != 3) {
          return ApiResponse.error('Invalid token format');
        }

        // Decode the payload
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final tokenData = jsonDecode(decoded);

        // Create user from token data
        final user = User(
          userId: tokenData['id'] ?? '',
          email: tokenData['email'] ?? '',
          fullname: tokenData['fullname'] ?? '',
          phonenumber: tokenData['phonenumber'] ?? '',
          address: tokenData['address'] ?? '',
          password: '', // We don't store the password
          role: tokenData['roles']?.isNotEmpty == true ? tokenData['roles'][0] : '',
          phone: tokenData['phone'] ?? '',
          image: tokenData['image']?? '',
        );

        // Store the user data
        await UserPreferences.setUser(user);
        return ApiResponse.completed(user);
      } catch (e) {
        print('Error extracting user data from token: $e');
        return ApiResponse.error('Failed to process user data from token');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      return ApiResponse.error('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<ApiResponse<User>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
    File? imageFile,
  ) async {
    try {
      if (imageFile != null) {
        // Use multipart request for image upload
        final uri = Uri.parse('${_apiClient.baseUrl}/account/update/$userId');
        final request = http.MultipartRequest('PUT', uri);

        // Add text fields
        updates.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        // Add image file
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

        // Add authorization header
        final token = await UserPreferences.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Send request
        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Handle successful response
          return ApiResponse.completed(User.fromJson(json.decode(responseData)));
        } else {
          final error = json.decode(responseData);
          return ApiResponse.error(error['message'] ?? 'Update failed');
        }
      } else {
        // Regular JSON update when no image is provided
        return await _apiClient.put(
          'account/update/$userId',
          updates,
          (json) => User.fromJson(json),
        );
      }
    } catch (e) {
      // Handle any errors that occur
      return ApiResponse.error('Error: ${e.toString()}');
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

  // Google login
  Future<ApiResponse<User>> googleLogin(String googleToken, String email, String fullname, String? photoUrl) async {
    try {
      final response = await _apiClient.post(
        'account/google-login',
        {
          'token': googleToken,
          'email': email,
          'fullname': fullname,
          'image': photoUrl
        },
        (json) {
          final userData = json['user'] as Map<String, dynamic>;
          final token = json['token'] as String;
          
          return User(
            userId: userData['_id'].toString(),
            email: userData['email'],
            fullname: userData['fullname'],
            phonenumber: userData['phonenumber'] ?? '',
            address: userData['address'] ?? '',
            password: '',
            role: (userData['roles'] as List?)?.isNotEmpty == true ? userData['roles'][0] : '',
            phone: userData['phonenumber'] ?? '',
            image: userData['image'],
            token: token
          );
        },
      );
      
      return response;
    } catch (e) {
      return ApiResponse.error('Error during Google login: $e');
    }
  }
}
