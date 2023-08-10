import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/image_strings.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../authentication/models/user_model.dart';

class ImageWithIcon extends StatelessWidget {
  const ImageWithIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future:  _getUserAvatar(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return Stack(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: FutureBuilder<String?>(
                    future: _getUserAvatar(),
                    builder: (context, avatarSnapshot) {
                      if (avatarSnapshot.hasData && avatarSnapshot.data != null) {
                        return Image.network(
                          'https://speech-assistive-app.com/assets/images/profile/${avatarSnapshot.data}',
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
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Icon(Icons.person, size: 120);
                          },
                        );
                      } else {
                        // Placeholder widget when avatar data is loading or not available
                        return const Placeholder();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          // Placeholder widget when user data is loading or not available
          return SizedBox(
            width: 120,
            height: 120,
            child: const Placeholder(),
          );
        }
      },
    );
  }

  Future<String?> _getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');
    final user = await UserRepository.instance.getUserDetails(currentUserEmail ?? '');
    return user.avatar;
  }
}

