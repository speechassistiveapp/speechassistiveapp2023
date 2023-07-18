import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_flutter_app/src/features/authentication/models/user_model.dart';
import 'package:login_flutter_app/src/repository/user_repository/user_repository.dart';
import '../../../repository/authentication_repository/authentication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final userRepo = UserRepository.instance; //Call Get.put(UserRepo) if not define in AppBinding file (main.dart)

  // TextField Controllers to get data from TextFields
  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();
  final  gender = RxString(''); // Initialize the gender property
  final avatar = TextEditingController(); // Add avatar field

  /// Loader
  final isLoading = false.obs;

  // As in the AuthenticationRepository we are calling _setScreen() Method
  // so, whenever there is change in the user state(), screen will be updated.
  // Therefore, when new user is authenticated, AuthenticationRepository() detects
  // the change and call _setScreen() to switch screens

  /// Register New User using either [EmailAndPassword] OR [PhoneNumber] authentication
  Future<void> createUser(UserModel user, ChildUser childUser) async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('email', user.email); // Save the email to preferences
      prefs.setString('pName', user.fullName); // Save the email to preferences
      prefs.setString('pGender', user.gender); // Save the email to preferences
      prefs.setString('pAvatar', user.avatar); // Save the email to preferences
      prefs.setBool('isLogged', false); // Save the email to preferences

      final childInfo = user.childInfo ?? '';
      if (childInfo.isNotEmpty) {
      final childInfoMap = jsonDecode(childInfo) as Map<String, dynamic>;

      final fullName = childInfoMap['FullName'];
      final gender = childInfoMap['Gender'];
      final avatar = childInfoMap['Avatar'];
      prefs.setString('cName', fullName); // Save the email to preferences
      prefs.setString('cGender', gender); // Save the email to preferences
      prefs.setString('cAvatar', avatar); // Save the email to preferences
    }// Save the email to preferences
      await emailAuthentication(user.email, user.password); //Perform authentication
      await userRepo.createUser(user,childUser); //Store Data in FireStore
      // AuthenticationRepository.instance.firebaseUser.refresh();
    } catch (e) {
      isLoading.value = false;
      print('Error: $e');
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    }
  }

  /// [EmailAuthentication]
  Future<void> emailAuthentication(String email, String password) async {
    try {
      await AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      throw e.toString();
    }
  }

  /// [PhoneNoAuthentication]
  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      await AuthenticationRepository.instance.phoneAuthentication(phoneNo);
    } catch (e) {
      throw e.toString();
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
}
