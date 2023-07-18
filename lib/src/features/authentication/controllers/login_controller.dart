import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../repository/authentication_repository/authentication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();

  /// Loader
  final isLoading = false.obs;

  /// Call this Function from Design & it will perform the LOGIN Op.
  Future<void> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email); // Save the email to preferences
      prefs.setBool('isLogged', true);  // Save the email to preferences
      await AuthenticationRepository.instance.loginWithEmailAndPassword(email, password);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }


  /// [GoogleSignInAuthentication]
  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      await AuthenticationRepository.instance.signInWithGoogle();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }

  /// [FacebookSignInAuthentication]
  Future<void> facebookSignIn() async {
    try {
      isLoading.value = true;
      await AuthenticationRepository.instance.signInWithFacebook();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }
}
