import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:pim_project/model/services/user_service.dart';

class UserRepository extends ChangeNotifier {
  final UserService userService;

  UserRepository({required this.userService});

  Future<ApiResponse<User>> login(String email, String password) {
    return userService.login(email, password);
  }


 // Update this method to call the correct service method
  Future<bool> signUpUser(User user) async {
    try {
      final response = await userService.signupUser(user); 

      if (response != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error signing up user: $e");
      return false;
    }
  }

  //
  Future<bool> sendOtpByEmail(String email) async {
    try {
      final response = await userService.sendOtpEmail(email);
      return response;
    } catch (e) {
      print("Error in UserRepository: $e");
      return false;
    }
  }

  


}
