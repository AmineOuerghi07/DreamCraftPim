import 'package:flutter/material.dart';
import 'package:pim_project/model/repositories/user_repository.dart';
import 'package:pim_project/model/services/UserPreferences%20.dart';
import 'package:pim_project/model/services/api_client.dart';


String user_id  = "";

class LoginViewModel with ChangeNotifier {
  final UserRepository userRepository;
  bool isLoading = false;
  String? errorMessage;
  LoginViewModel({required this.userRepository});

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;  // Réinitialisation de l'erreur au début
    notifyListeners();

    try {
      final response = await userRepository.login(email, password);

      if (response != null && response.status == Status.COMPLETED) {
         user_id = await UserPreferences.getUserId() ?? "";

      } else {
        errorMessage = response?.message ?? "Une erreur inconnue s'est produite.";
      }
    } catch (e) {
      errorMessage = "Erreur de connexion : ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }




  
}
