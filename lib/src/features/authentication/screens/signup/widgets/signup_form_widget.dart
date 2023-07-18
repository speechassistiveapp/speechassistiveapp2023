import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login_flutter_app/src/features/authentication/models/user_model.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/signup_controller.dart';

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final formKey = GlobalKey<FormState>();
    final avatar = TextEditingController();


    return Container(
      padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller.fullName,
              decoration: const InputDecoration(label: Text(tFullName), prefixIcon: Icon(LineAwesomeIcons.user)),
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.email,
              decoration: const InputDecoration(label: Text(tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope)),
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.phoneNo,
              decoration: const InputDecoration(label: Text(tPhoneNo), prefixIcon: Icon(LineAwesomeIcons.phone)),
            ),
            const SizedBox(height: tFormHeight - 20),
            // Add gender selection widget
            DropdownButtonFormField<String>(
              //value: 'Male', // Assuming you have a gender property in the controller
              onChanged: (value) {
                controller.gender.value = value!;
              },
              decoration: const InputDecoration(label: Text('Gender')),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a gender';
                }
                return null;
              },
            ),
            const SizedBox(height: tFormHeight - 20),
            TextFormField(
              controller: controller.password,
              decoration: const InputDecoration(label: Text(tPassword), prefixIcon: Icon(Icons.fingerprint)),
            ),
            const SizedBox(height: tFormHeight - 10),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      /// Email & Password Authentication
                      // SignUpController.instance.registerUser(controller.email.text.trim(), controller.password.text.trim());

                      /// For Phone Authentication
                      // SignUpController.instance.phoneAuthentication(controller.phoneNo.text.trim());

                      /*
                       =========
                       Todo:Step - 3 [Get User and Pass it to Controller]
                       =========
                      */
                      final user = UserModel(
                        email: controller.email.text.trim(),
                        password: controller.password.text.trim(),
                        fullName: controller.fullName.text.trim(),
                        phoneNo: controller.phoneNo.text.trim(),
                        gender: controller.gender.value,
                        avatar: controller.avatar.text,
                      );
                      
                      showAvatarSelectionPopup(context, controller.avatar,controller.gender.value,user);
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
                      : Text("Next".toUpperCase()),//Text(tSignup.toUpperCase()),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


void showAvatarSelectionPopup(BuildContext context, TextEditingController avatarController, String selectedGender,UserModel user) {
  final int numAvatars = 4; // Specify the number of avatars

  List<Map<String, String>> avatarOptions = [];

  String sGend = selectedGender + 'Avatar';

  avatarOptions = List.generate(numAvatars, (index) {
    final avatarNumber = index + 1;
    final imagePath = 'assets/images/profile/$sGend$avatarNumber.png';
    final value = '$sGend$avatarNumber';

    return {
      'imagePath': imagePath,
      'value': value,
    };
  });

  final columns = 2;
  final rows = (avatarOptions.length / columns).ceil();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Avatar"),
        content: Container(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: columns,
            children: List.generate(avatarOptions.length, (index) {
              final avatarOption = avatarOptions[index];
              return InkWell(
                onTap: () {
                  avatarController.text = avatarOption['value']!;
                  Navigator.pop(context);

                  // Show the child signup popup
                  showChildSignupPopup(context, avatarController.text, selectedGender,user,);
                },
                child: Image.asset(avatarOption['imagePath']!),
              );
            }),
          ),
        ),
      );
    },
  );
}

void showChildSignupPopup(BuildContext context, String avatarValue, String selectedGender,UserModel user) {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final genderController = TextEditingController();
  final avatarController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Child Signup"),
        content: Container(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(label: Text("Full Name")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  //value: selectedGender,
                  onChanged: (value) {
                    genderController.text = value!;
                  },
                  decoration: const InputDecoration(label: Text("Gender")),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a gender';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Get the entered full name and selected gender
                final fullName = fullNameController.text.trim();
                final selectedGender = genderController.text.trim();

                // Close the current popup
                Navigator.pop(context);

                // Show the avatar selection popup
                showChildAvatarSelectionPopup(context, avatarController, selectedGender,fullName,user,avatarValue);
              }
            },
            child: Text("Next"),
          ),
        ],
      );
    },
  );
}

void showChildAvatarSelectionPopup(BuildContext context, TextEditingController avatarController, String selectedGender, String fullName,UserModel user,String avatarValue) {
  final int numAvatars = 2; // Specify the number of avatars

  List<Map<String, String>> avatarOptions = [];

  String sGend = '';

  if (selectedGender == 'Male') {
    sGend = 'BoyAvatar';
  } else if (selectedGender == 'Female') {
    sGend = 'GirlAvatar';
  }

  avatarOptions = List.generate(numAvatars, (index) {
    final avatarNumber = index + 1;
    final imagePath = 'assets/images/profile/$sGend$avatarNumber.png';
    final value = '$sGend$avatarNumber';

    return {
      'imagePath': imagePath,
      'value': value,
    };
  });

  final columns = 2;
  final rows = (avatarOptions.length / columns).ceil();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Avatar"),
        content: Container(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: columns,
            children: List.generate(avatarOptions.length, (index) {
              final avatarOption = avatarOptions[index];
              return InkWell(
                onTap: () {
                  avatarController.text = avatarOption['value']!;
                  Navigator.pop(context);

                  // Perform any action with the selected avatar, gender, and full name
                  // For example, create a child user with these values
                  final selectedAvatar = avatarOption['value']!;

                  final childUser = ChildUser(
                  fullName: fullName,
                  gender: selectedGender,
                  avatar: selectedAvatar,
                );

                

                  // Create the user with the user information and child user
                  final userData = UserModel(
                    email: user.email,
                    password: user.password,
                    fullName: user.fullName,
                    phoneNo: user.phoneNo,
                    gender: user.gender,
                    avatar: avatarValue,
                  );
                  // Print the userData and childUser for debugging
                  print('userData: ${userData.toJson()}');
                  print('childUser: ${childUser.toJson()}');


                // Create the user with the user information and child user
                SignUpController.instance.createUser(userData, childUser);
                  
                },
                child: Image.asset(avatarOption['imagePath']!),
              );
            }),
          ),
        ),
      );
    },
  );
}