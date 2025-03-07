// view_model/signup_view_model.dart
import 'package:flutter/material.dart';
import 'package:pim_project/model/domain/user.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/api_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupViewModel with ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;
  User? currentUser;

  SignupViewModel({required this.userRepository});

  Future<bool> signup(String fullname, String email, String phonenumber, String address, String password, String role) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create a User object
      User user = User(
        userId: '', // Will be assigned by the server
        fullname: fullname,
        email: email,
        phonenumber: phonenumber,
        address: address,
        password: password,
        role: role,
      );

      // Pass the User object to the repository
      final response = await userRepository.signUpUser(user);

      if (response.status == Status.COMPLETED && response.data != null) {
        currentUser = response.data;
        _showSuccessToast("Compte créé avec succès");
        return true;
      } else {
        errorMessage = response.message ?? "Échec de la création du compte";
        _showErrorToast(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = "Erreur lors de l'inscription : ${e.toString()}";
      _showErrorToast(errorMessage!);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validate password strength
  bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  // Validate phone number
  bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s-]{8,}$').hasMatch(phone);
  }

  // Helper methods for showing toasts
  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}
