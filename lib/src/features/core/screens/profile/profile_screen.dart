import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login_flutter_app/src/constants/sizes.dart';
import 'package:login_flutter_app/src/constants/text_strings.dart';
import 'package:login_flutter_app/src/features/core/screens/profile/update_profile_screen.dart';
import 'package:login_flutter_app/src/features/core/screens/profile/widgets/image_with_icon.dart';
import 'package:login_flutter_app/src/features/core/screens/profile/widgets/profile_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/colors.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../repository/user_repository/user_repository.dart';
import '../../../authentication/models/user_model.dart';
import 'all_users.dart';
import 'edit_child_profile.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(tProfile, style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: FutureBuilder<UserModel>(
        future: UserRepository.instance.getUserDetails('email@example.com'), // Replace 'email@example.com' with the actual email of the logged-in user
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(tDefaultSize),
                child: Column(
                  children: [
                    /// -- IMAGE with ICON
                    const ImageWithIcon(),
                    const SizedBox(height: 10),
                    Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
                    Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    /// -- BUTTON
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => _showEditProfileModal(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimaryColor, side: BorderSide.none, shape: const StadiumBorder()),
                        child: const Text(tEditProfile, style: TextStyle(color: tDarkColor)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),

                    

                    /// -- MENU
                    ProfileMenuWidget(title: "Child Profile", icon: LineAwesomeIcons.user_check, onPress: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final cName = prefs.getString('cName') ?? '';
                      final cGender = prefs.getString('cGender') ?? '';
                      final cAvatar = prefs.getString('cAvatar') ?? '';
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        print("User Details: ${user.toString()}");

                        final childInfo = user.childInfo ?? '';
                        final childInfoMap = jsonDecode(childInfo) as Map<String, dynamic>;

                        final fullName = childInfoMap['FullName'];
                        final gender = childInfoMap['Gender'];
                        final avatar = childInfoMap['Avatar'];

                        print('fullName: $fullName');
                        print('gender: $gender');
                        print('avatar: $avatar');

                          return AlertDialog(
                            title: Text("Child Profile"),
                            content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    
    // Conditional check for displaying the image or placeholder icon
              avatar != null
                  ? Image.network(
                      'https://speech-assistive-app.com/assets/images/profile/${cAvatar}',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          LineAwesomeIcons.user, // Placeholder icon
                          size: 120,
                        );
                      },
                    )
                  : Icon(
                      LineAwesomeIcons.user, // Placeholder icon
                      size: 120,
                    ),
              const SizedBox(height: 10),
              
              Text(cName, style: Theme.of(context).textTheme.headlineMedium),
              Text(cGender),
            ],
          ),

                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Close"),
                              ),TextButton(
                                onPressed: () => _showEditChildProfileModal(context),
                                child: Text("Update"),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    const Divider(),
                    const SizedBox(height: 10),
                    ProfileMenuWidget(title: "About", icon: LineAwesomeIcons.info, onPress: () {}),
                    ProfileMenuWidget(
                        title: "Logout",
                        icon: LineAwesomeIcons.alternate_sign_out,
                        textColor: Colors.red,
                        endIcon: false,
                        onPress: () {
                          Get.defaultDialog(
                            title: "LOGOUT",
                            titleStyle: const TextStyle(fontSize: 20),
                            content: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              child: Text("Are you sure you want to logout?"),
                            ),
                            confirm: Expanded(
                              child: ElevatedButton(
                                onPressed: () => AuthenticationRepository.instance.logout(),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, side: BorderSide.none),
                                child: const Text("Yes"),
                              ),
                            ),
                            cancel: OutlinedButton(onPressed: () => Get.back(), child: const Text("No")),
                          );
                        }),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle the error state
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Display a loading indicator while waiting for data
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

void _showEditProfileModal(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile'),
          ),
          body: EditProfileModal(),
        );
      },
    ),
  );
}

void _showEditChildProfileModal(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Child Profile'),
          ),
          body: EditChildProfileModal(),
        );
      },
    ),
  );
}
