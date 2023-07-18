import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

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
    return FutureBuilder<UserModel>(
      future: UserRepository.instance.getUserDetails('email@example.com'), // Replace 'email@example.com' with the actual email of the logged-in user
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
                  child: Image.asset('assets/images/profile/${user.avatar}.png'),
                ),
              ),
              /*Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: tPrimaryColor,
                  ),
                  child: const Icon(
                    LineAwesomeIcons.alternate_pencil,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),*/
            ],
          );
        } else {
          // Placeholder widget when data is loading or not available
          return SizedBox(
            width: 120,
            height: 120,
            child: const Placeholder(),
          );
        }
      },
    );
  }
}
