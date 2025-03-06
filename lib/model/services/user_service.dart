import 'package:dio/dio.dart';
import 'package:pim_project/main.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/UserPreferences%20.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final   apiClient;
    final Dio dio = Dio();


  UserService({required this.apiClient});

    Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        'http://192.168.161.220:3000/account/sign-in',
        data: {'email': email, 'password': password},
      );

     if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

         // Store userId
      await UserPreferences.setUserId(data['userId']);
      MyApp.userId = data['userId'];

  print("Login successful. userId: ${MyApp.userId}");
        // Print userId for debugging
        print("This user id is ${data['userId']}");

        // Build the user object with userId
        User user = User(
          userId: data['userId'],
          fullname: "",
          email: "",
          password: "",
          phonenumber: "",
          address: "",
          role: "",
        );

        return ApiResponse.completed(user);
      } else {
        return ApiResponse.error('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error during login: $e');
    }
  }

   Future<User?> signupUser(User user) async {
    try {
      final response = await dio.post(
        'http://192.168.161.220:3000/account/sign-up',
        data: user.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  ////
  Future<bool> sendOtpEmail(String email) async {
  try {
    final response = await dio.post(
      'http://192.168.161.220:3000/account/forgot-password-otp-email', 
      data: {'email': email},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Error sending OTP: $e");
    return false;
  }
}

Future<User?> googleLogin(String googleToken) async {
  try {
    final response = await dio.post(
      'http://192.168.161.220:3000/account/google-login', 
      data: {'google_token': googleToken},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(response.data); // Ensure User model is correctly structured
    } else {
      print("Google login failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("Error during Google login: $e");
  }
  return null;
}






  ///




}
