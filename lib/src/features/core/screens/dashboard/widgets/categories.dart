import 'package:flutter/material.dart';
import 'package:login_flutter_app/src/constants/colors.dart';

import '../../../models/dashboard/categories_model.dart';
import '../todolist/screens/HomeScreen.dart';
import '../todolist/utils/AppAssets.dart';

class DashboardCategories extends StatelessWidget {
  const DashboardCategories({
    Key? key,
    required this.txtTheme,
  }) : super(key: key);

  final TextTheme txtTheme;

  @override
  Widget build(BuildContext context) {
    final list = DashboardCategoriesModel.list;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Set the desired border radius here
      child: Container(
        color: tCardBgColor, // Set your desired background color here
        child: SizedBox(
          height: 80,
          child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: SizedBox(
                width: 310,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 109, 168, 226),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAssets.note,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 180,
                      height: 50, // Set the desired height
                      color: tCardBgColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            list[index].heading,
                            style: txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            list[index].subHeading,
                            style: txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
