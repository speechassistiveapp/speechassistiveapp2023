import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login_flutter_app/src/features/authentication/controllers/login_controller.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../forget_password/forget_password_options/forget_password_model_bottom_sheet.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final controller = Get.put(LoginController());
  final formKey = GlobalKey<FormState>();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == '' || value == null) {
                    return "Add your Email";
                  } else if (!GetUtils.isEmail(value)) {
                    return "Invalid Email Address";
                  } else {
                    return null;
                  }
                },
                controller: controller.email,
                decoration: const InputDecoration(
                  prefixIcon: Icon(LineAwesomeIcons.user),
                  labelText: tEmail,
                  hintText: tEmail,
                ),
              ),
              const SizedBox(height: tFormHeight - 20),
              TextFormField(
                obscureText: !showPassword,
                controller: controller.password,
                validator: (value) {
                  if (value == '' || value == null) {
                    return "Enter your Password";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.fingerprint),
                  labelText: tPassword,
                  hintText: tPassword,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    child: Icon(showPassword ? LineAwesomeIcons.eye : LineAwesomeIcons.eye_slash),
                  ),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              /// -- FORGET PASSWORD BTN
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ForgetPasswordScreen.buildShowModalBottomSheet(context),
                  child: const Text(tForgetPassword),
                ),
              ),

              /// -- LOGIN BTN
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? () {}
                        : () {
                            if (formKey.currentState!.validate()) {
                              LoginController.instance
                                  .loginUser(controller.email.text.trim(), controller.password.text.trim());
                            }
                          },
                    child: controller.isLoading.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("Loading...")
                            ],
                          )
                        : Text(tLogin.toUpperCase()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
