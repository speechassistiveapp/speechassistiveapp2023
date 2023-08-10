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
    final defaultImagePath = 'https://speech-assistive-app.com/assets/images/profile/profile-pic.png';
    return FutureBuilder<UserModel>(
      future: UserRepository.instance.getUserDetails('email@example.com'), // Replace 'email@example.com' with the actual email of the logged-in user
      builder: (context, snapshot) {
        // Wrap the builder function with an async function
        return FutureBuilder<String>(
          future: _loadCAvatar(), // Load the pAvatar value
          builder: (context, avatarSnapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          final imagePath = 'https://speech-assistive-app.com/assets/images/profile/${avatarSnapshot.data}';
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
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
  icon: Image.network(
    '$imagePath?timestamp=${DateTime.now().millisecondsSinceEpoch}',
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      );
    },
  ),
),

              ),
            ],
          );
        } else if (snapshot.hasError) {
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
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
                  icon: Image.network(
                    defaultImagePath,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return AppBar(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
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
                  icon: Image.network(
                    defaultImagePath,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
          }
        );
      },
    );
  }

   // Define an async function to load the pAvatar value from SharedPreferences
  Future<String> _loadCAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final pAvatar = prefs.getString('pAvatar') ?? ''; // Provide a default value if pAvatar is not found
    return pAvatar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(55);
}
