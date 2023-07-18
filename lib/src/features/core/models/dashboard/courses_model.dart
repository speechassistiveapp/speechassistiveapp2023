import 'package:flutter/material.dart';
import 'package:login_flutter_app/src/constants/image_strings.dart';

class DashboardTopCoursesModel{
  final String title;
  final String heading;
  final String subHeading;
  final String image;
  final VoidCallback? onPress;

  DashboardTopCoursesModel(this.title, this.heading, this.subHeading, this.image, this.onPress);

  static List<DashboardTopCoursesModel> list = [
    DashboardTopCoursesModel("Learn New Phrases", "Join me!", "Together let's learn!", tTopCourseImage1, (){}),
    //DashboardTopCoursesModel("HTML/ CSS Crash Course", "2 Sections", "35 Lessons", tTopCourseImage2, null),
    //DashboardTopCoursesModel("Material Design Course", "6 Sections", "Programming & Design", tTopCourseImage1, (){}),
  ];
}