import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskModel {
  final String title;
  final String description;
  final String time;
  final String endtime;
  final bool taskstat;
  final List<bool> frequencyList;

  const TaskModel({
    required this.title,
    required this.description,
    required this.time,
    required this.endtime,
    required this.taskstat,
    required this.frequencyList,
  });
}

Stream<List<TaskModel>> fetchTaskListFromFirebase() async* {
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

    final taskListStream = documentReference.snapshots().map<List<TaskModel>>((snapshot) {
      final existingTaskList = snapshot.data()?['taskList'] ?? [];

      return existingTaskList.map<TaskModel>((taskData) {
        final List<bool> frequencyList = taskData['frequency'] != null
            ? List<bool>.from(taskData['frequency'])
            : [];

        return TaskModel(
          title: taskData['taskName'] ?? '',
          description: taskData['description'] ?? '',
          time: taskData['startTime'] ?? '',
          endtime: taskData['endTime'] ?? '',
          taskstat: taskData['taskstat'] ?? false,
          frequencyList: frequencyList,
        );
      }).toList();
    });

    yield* taskListStream;
  } catch (error) {
    print('Failed to retrieve taskList from Firestore: $error');
    yield [];
  }
}

