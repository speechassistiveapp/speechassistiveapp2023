import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddScreenController extends GetxController {
  var categoryList = ['Urgent', 'Routine', 'Optional'];

  var selectedIndex = 0;
  void setIndex(int index) {
    selectedIndex = index;
    update();
  }

  List<bool> frequencyList = [false, false, false, false, false, false, false]; // Initial selection status for each day

  void setFrequency(int index, bool value) {
    frequencyList[index] = value;
    update();
  }

  String startTime = ''; // Default start time
  String endTime = ''; // Default end time
  void setStartTime(String time) {
    startTime = time;
    update();
  }

  void setEndTime(String time) {
    endTime = time;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize start time and end time with current date and time only if they are empty
    if (startTime.isEmpty) {
      final now = DateTime.now();
      final formattedStartTime = DateFormat('hh:mm a').format(now);
      final formattedEndTime = DateFormat('hh:mm a').format(now.add(Duration(hours: 1)));

      startTime = formattedStartTime;
      endTime = formattedEndTime;

      update();
    }
  }
}
