import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AddScreenController.dart';
import '../utils/AppAssets.dart';
import '../utils/AppSpaces.dart';
import '../widgets/FormElements.dart';
import '../widgets/buttons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AddScreen extends StatelessWidget {
  
  AddScreen({Key? key}) : super(key: key);
  final AddScreenController controller = Get.put(AddScreenController());
  List<bool> frequencyList = [false, false, false, false, false, false, false]; // Initial selection status for each day
  String _getDayLabel(int index) {
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


    String taskName = '';
    String description = '';



  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddScreenController>(
      //init: AddScreenController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          AppSpaces.vertical30,
          Row(children: [
            AppSpaces.horizontal10,
            IconButton(onPressed: Get.back, icon: ImageIcon(AssetImage(AppAssets.arrow))),
            Spacer(),
            GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Urgent',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                ),
                TextSpan(text: '   tasks require immediate attention and should be completed as soon as possible.\n\n'),
                TextSpan(
                  text: 'Routine',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                ),
                TextSpan(text: '  tasks are recurring or repetitive tasks that need to be completed regularly.\n\n'),
                TextSpan(
                  text: 'Optional',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                ),
                TextSpan(text: '  tasks are tasks that are not essential or mandatory for the completion of a project or goal.'),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  },
  child: Icon(
    Icons.info,
    color: const Color.fromARGB(255, 0, 0, 0),
    size: 40,
  ),
),

            AppSpaces.horizontal20,
          ]),
          AppSpaces.vertical30,
          Row(children: [
            AppSpaces.horizontal30,
            Text(
              'Create New Task',
              style: TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpaces.horizontal30,
          ]),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AppSpaces.vertical25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  children: [
                    Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 109, 168, 226),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpaces.vertical25,
              Container(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categoryList.length,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  separatorBuilder: (context, index) => AppSpaces.horizontal15,
                  itemBuilder: (context, index) => CategoryButton(
                    label: controller.categoryList[index],
                    isSelected: controller.selectedIndex == index,
                    onTap: () {
                    controller.setIndex(index);
                  },
                  ),
                ),
              ),
              AppSpaces.vertical25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        4, // Number of checkboxes for the first row (Monday to Thursday)
                        (index) => Row(
                          children: [
                            Checkbox(
                              value: controller.frequencyList[index],
                             onChanged: (value) {
                              controller.setFrequency(index, value!);
                            },
                            ),
                            Text(_getDayLabel(index)),
                          ],
                        ),
                      ).expand((widget) => [widget, SizedBox(width: 2)]).toList(),
                    ),
                    Row(
                      children: List.generate(
                        3, // Number of checkboxes for the second row (Friday to Saturday)
                        (index) => Row(
                          children: [
                            Checkbox(
                              value: controller.frequencyList[index + 4], // Add 4 to the index to start from Friday
                              onChanged: (value) {
                                controller.setFrequency(index + 4, value!); // Add 4 to the index to start from Friday
                              },
                            ),
                            Text(_getDayLabel(index + 4)), // Add 4 to the index to start from Friday
                          ],
                        ),
                      ).expand((widget) => [widget, SizedBox(width: 2)]).toList(),
                    ),
                  ],
                ),
              ),

              AppSpaces.vertical25,
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30.0),
  child: Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: 10, minute: 0),
            );
            if (selectedTime != null) {
              // Handle the selected time here
              String formattedTime =
                  '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
              // Update the value in your controller or state
              controller.setStartTime(formattedTime);
            }
          },
          child: AbsorbPointer(
            child: AppTextField(
              label: 'Start Time',
              value: controller.startTime,
              suffix: Image.asset(
                AppAssets.arrow_down,
                width: 25,
              ), onChanged: (value) { },
            ),
          ),
        ),
      ),
      AppSpaces.horizontal20,
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: 11, minute: 0),
            );
            if (selectedTime != null) {
              // Handle the selected time here
              String formattedTime =
                  '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
              // Update the value in your controller or state
              controller.setEndTime(formattedTime);
            }
          },
          child: AbsorbPointer(
            child: AppTextField(
              label: 'End Time',
              value: controller.endTime,
              suffix: Image.asset(
                AppAssets.arrow_down,
                width: 25,
              ), onChanged: (value) { },
            ),
          ),
        ),
      ),
    ],
  ),
),


              
              AppSpaces.vertical25,
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0), // Adjust the border radius as desired
                    ),
                  ),
                  controller: TextEditingController(text: ''),
                  onChanged: (value) {
                    taskName = value;
                  },
                ),
              ),
              AppSpaces.vertical25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0), // Adjust the border radius as desired
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 3,
                  controller: TextEditingController(text: ''),
                  onChanged: (value) {
                    description = value;
                  },
                ),
              ),


              AppSpaces.vertical25,
              Center(
                child: AppButton(
                  label: 'Create Task',
                  onTap: () => _createTask(context),
                ),

              ),
              AppSpaces.vertical25,
            ],
          )),
        ]),
      ),
    );
  }

    void _createTask(BuildContext context) async {
  // Get the task data from the controller
  //String taskName = controller.taskName;
  String category = controller.categoryList[controller.selectedIndex];
  List<bool> frequency = controller.frequencyList;
  String startTime = controller.startTime;
  String endTime = controller.endTime;
  bool taskstat = true;
  //String description = controller.description;

  // Validate the task data (you can add your own validation logic)

  // Create a map to represent the task data
  Map<String, dynamic> taskData = {
    'taskName': taskName,
    'category': category,
    'frequency': frequency,
    'startTime': startTime,
    'endTime': endTime,
    'description': description,
    'taskstat': taskstat,

  };

  try {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');

    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('Email', isEqualTo: currentUserEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final documentReference = snapshot.docs.first.reference;

    // Get the existing taskList data
    final existingTaskList = await documentReference.get();
    final taskListData = existingTaskList.data()?['taskList'] ?? [];

    // Add the new task to the taskList
    taskListData.add(taskData);

    // Update the taskList in Firestore
    await documentReference.update({
      'taskList': taskListData,
    });

    print('Task created successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task created successfully'),
      ),
    );
    Get.back();
  } catch (error) {
    print('Error creating task: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error creating task'),
      ),
    );
  }
}

}

