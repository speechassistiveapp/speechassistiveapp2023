import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/HomeScreenController.dart';
import '../models/TaskModel.dart';
import '../screens/AddScreen.dart';
import '../utils/AppAssets.dart';
import '../utils/AppSpaces.dart';
import '../widgets/Scrollbar.dart';
import '../widgets/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenController controller = Get.put(HomeScreenController());
  List<TaskModel> taskList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      builder: (controller) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Home Screen'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigates back to the previous screen (CategoriesScreen)
              },
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    color: Color.fromARGB(255, 109, 168, 226),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          //AppSpaces.vertical25,
                          Row(children: [
                            AppSpaces.horizontal30,
                            Text(
                              'My Task',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () => Get.to(() => AddScreen()),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 109, 168, 226),
                                ),
                                width: 50,
                                height: 50,
                                child: Center(
                                    child: Image.asset(
                                  AppAssets.plus,
                                  width: 20,
                                  height: 20,
                                )),
                              ),
                            ),
                            AppSpaces.horizontal30,
                          ]),
                          AppSpaces.vertical15,
                          Row(children: [
                            AppSpaces.horizontal30,
                            Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              DateFormat(' EEEE: MMMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                color: Get.theme.colorScheme.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            AppSpaces.horizontal30,
                          ]),
                          AppSpaces.vertical15,
                          Container(
                            height: 60,
                            padding: EdgeInsets.only(left: 30),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                final currentDate = DateTime.now();
                                final day = currentDate.add(Duration(days: index));
                                final isSelected = index == 0; // Set isSelected to true for the current day

                                return Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: IgnorePointer(
                                    ignoring: true, // Disable user interaction
                                    child: DayButton(
                                      dayNumber: day.day,
                                      character: controller.getWeekOfDaysFirstLettersByIndex(day.weekday - 1),
                                      isSelected: isSelected,
                                      onTap: () {
                                        // No need for the onTap function since it's disabled
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          AppSpaces.vertical20,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 109, 168, 226),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
                        ),
                        padding: EdgeInsets.only(top: 30),
                        child: Row(children: [
                          AppSpaces.horizontal30,
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Obx(
                              () => CustomPaint(
                                willChange: true,
                                painter: ScrollPainter(
                                  progress: controller.progress.value,
                                  barHeight: 30,
                                ),
                                child: Container(
                                    width: 2,
                                    height: Get.height,
                                    child: SizedBox(
                                      height: controller.progress.value,
                                    )),
                              ),
                            ),
                          ),
                          AppSpaces.horizontal30,
                          Expanded(
  child: StreamBuilder<List<TaskModel>>(
    stream: fetchTaskListFromFirebase(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Error retrieving tasks'),
        );
      }

      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      final List<TaskModel> taskList = snapshot.data!;

      return ListView.separated(
  controller: controller.scrollController,
  itemCount: taskList.length,
  padding: EdgeInsets.only(bottom: 30),
  separatorBuilder: (context, index) => AppSpaces.vertical30,
  itemBuilder: (context, index) {
    if (taskList[index].taskstat) {
      return TaskCard(task: taskList[index]);
    } else {
      return SizedBox(); // Don't display the task card if taskstat is false
    }
  },
);

    },
  ),
),

                          AppSpaces.horizontal25,
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  final TaskModel task;

  
  String _getDayLabel(int index) {
  switch (index) {
    case 0:
      return 'M';
    case 1:
      return 'T';
    case 2:
      return 'W';
    case 3:
      return 'T';
    case 4:
      return 'F';
    case 5:
      return 'S';
    case 6:
      return 'S';
    default:
      return '';
  }
  }

  Future<void> updateTaskStat(bool newTaskStat) async {
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

      final List<Map<String, dynamic>> existingTaskList =
          (await documentReference.get()).data()?['taskList']?.cast<Map<String, dynamic>>() ?? [];

      final updatedTaskList = existingTaskList.map((taskData) {
        if (taskData['taskName'] == task.title && taskData['description'] == task.description) {
          taskData['taskstat'] = newTaskStat;
        }
        return taskData;
      }).toList();

      await documentReference.update({
        'taskList': updatedTaskList,
      });
    } catch (error) {
      print('Failed to update task stat in Firestore: $error');
    }
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                updateTaskStat(false); // Set taskstat to false for delete
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 5, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppSpaces.vertical5,
                    Text(
                      task.description,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final bool isFilled =
                            index < task.frequencyList.length && task.frequencyList[index];

                        return Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isFilled ? Colors.blue : Colors.transparent,
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Center(
                            child: Text(
                              _getDayLabel(index),
                              style: TextStyle(
                                color: isFilled ? Colors.white : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDeleteConfirmation(context);
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              color: const Color.fromARGB(255, 28, 28, 28),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              task.time + ' - ' + task.endtime,
              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
