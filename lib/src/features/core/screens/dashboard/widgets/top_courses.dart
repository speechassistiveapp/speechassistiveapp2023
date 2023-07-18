import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/sizes.dart';
import '../../../models/dashboard/courses_model.dart';
import '../drills/homepage.dart';

class DashboardTopCourses extends StatelessWidget {
  const DashboardTopCourses({
    Key? key,
    required this.txtTheme,
    required this.isDark,
  }) : super(key: key);

  final TextTheme txtTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final list = DashboardTopCoursesModel.list;
    return SizedBox(
      height: 210,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: (){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
            print('This is being clicked!');
          }, // Wrap the GestureDetector around the entire card
          child: SizedBox(
            width: 320,
            height: 210,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDark ? tSecondaryColor : tCardBgColor,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            list[index].title,
                            style: txtTheme.headlineMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(child: Image(image: AssetImage(list[index].image), height: 110)),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: Color.fromARGB(255, 92, 192, 152)),
                          onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyHomePage()),
                          );},
                          child: const Icon(Icons.mic),
                        ),
                        const SizedBox(width: tDashboardCardPadding),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list[0].heading,
                              style: txtTheme.headlineMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              list[0].subHeading,
                              style: txtTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
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
