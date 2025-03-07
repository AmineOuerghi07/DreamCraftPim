import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/repositories/user_repository.dart';

class SignupViewModel with ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;

  SignupViewModel({required this.userRepository});

  Future<void> signup(String fullname, String email, String phonenumber, String address, String password, String role) async {
    isLoading = true;
    notifyListeners();

    try {
          String userId = '';  

      // Create a User object
      User user = User(
        userId: userId, 
        fullname: fullname,
        email: email,
        phonenumber: phonenumber,
        address: address,
        password: password,
        role: role,
      );

      // Pass the User object to the repository
      bool isSuccess = await userRepository.signUpUser(user);
      if (isSuccess) {
        // Handle success if necessary
      } else {
        errorMessage = 'Failed to create user. Please try again.';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
