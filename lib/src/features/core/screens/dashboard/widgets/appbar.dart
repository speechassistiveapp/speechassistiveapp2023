import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_strings.dart';
import '../../../../../constants/text_strings.dart';
import '../../profile/profile_screen.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../authentication/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final imagePath = 'assets/images/profile/profile-pic.png';
    return FutureBuilder<UserModel>(
      future: UserRepository.instance.getUserDetails('email@example.com'), // Replace 'email@example.com' with the actual email of the logged-in user
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final imagePath = 'assets/images/profile/${user.avatar}.png';
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            //leading: Icon(Icons.menu, color: isDark ? tWhiteColor : tDarkColor),
            title: Text('Hi ${user.fullName.split(' ')[0]}', style: Theme.of(context).textTheme.headlineMedium),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 20, top: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                child: IconButton(
                  onPressed: () => Get.to(new ProfileScreen()),
                  // onPressed: () => AuthenticationRepository.instance.logout(),
                  icon: Image(image: AssetImage(imagePath)),
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            //leading: Icon(Icons.menu, color: isDark ? tWhiteColor : tDarkColor),
            title: Text('Hi User', style: Theme.of(context).textTheme.headlineMedium),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 20, top: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                child: IconButton(
                  onPressed: () => Get.to(new ProfileScreen()),
                  // onPressed: () => AuthenticationRepository.instance.logout(),
                  icon: Image(image: AssetImage(imagePath)),
                ),
              )
            ],
          );
        } else {
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            //leading: Icon(Icons.menu, color: isDark ? tWhiteColor : tDarkColor),
            title: const Text('Hi User', style: TextStyle(fontSize: 20)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 20, top: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                child: IconButton(
                  onPressed: () => Get.to(new ProfileScreen()),
                  // onPressed: () => AuthenticationRepository.instance.logout(),
                  icon: Image(image: AssetImage(imagePath)),
                ),
              )
            ],
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
