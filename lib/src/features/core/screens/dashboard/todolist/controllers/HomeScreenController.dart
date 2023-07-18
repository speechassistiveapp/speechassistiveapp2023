import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeScreenController extends GetxController {
  int selectedIndex = 0;
  var scrollController = ScrollController();

  var progress = 0.0.obs;

  @override
  void onInit() {
    scrollController.addListener(() {
      onScroll();
    });
    super.onInit();
  }

  void onScroll() {
    if (scrollController.hasClients) {
      progress.value = scrollController.offset / scrollController.position.maxScrollExtent;
    }
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }

  String getWeekOfDaysFirstLettersByIndex(int index) {
    switch (index) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }

  
}
