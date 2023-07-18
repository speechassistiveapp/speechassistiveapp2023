import 'package:flutter/material.dart';
import 'package:login_flutter_app/src/constants/sizes.dart';
import 'package:login_flutter_app/src/constants/text_strings.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/widgets/appbar.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/widgets/banners.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/widgets/categories.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/widgets/search.dart';
import 'package:login_flutter_app/src/features/core/screens/dashboard/widgets/top_courses.dart';
import 'package:intl/intl.dart';
//import '../dashboard/todolist/models/TaskModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {

  final player = AudioPlayer(); //audio player obj that will play audio
  bool _isLoadingVoice = false; //for the progress indicator
  late List<Map<String, dynamic>> taskList;
  int currentTaskIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      fetchTaskList();
    });
  }

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

  Future<void> playTextToSpeechParent(String text, String gender) async {
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator turn on now
    });

    String voiceId = ''; // Initialize the voiceId variable

    if (gender == 'Male') {
      voiceId = 'pNInz6obpgDQGcFmaJgB'; // Male voiceId
    } else {
      voiceId = 'EXAVITQu4vr4xnSDxMaL'; // Female voiceId
    }

    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId/stream';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': '0dd59ced7b4d1fb0ca0f53d70134ac11',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    setState(() {
      _isLoadingVoice = false; //progress indicator turn off now
    });

    if (response.statusCode == 200) {
      _isLoadingVoice = false;
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }
  } //getResponse from Eleven Labs

  Future<void> fetchTaskList() async {
    try {
      setState(() {
        isLoading = true;
      });

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

      final existingTaskList =
          (await documentReference.get()).data()?['taskList']?.cast<Map<String, dynamic>>() ?? [];

      setState(() {
        taskList = existingTaskList;
        isLoading = false;
      });

      print('Fetched taskList: $taskList'); // Debug print to display the fetched data

      showTaskModal();
    } catch (error) {
      print('Failed to fetch taskList from Firestore: $error');
    }
  }

void showTaskModal() {
  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final currentTime = DateFormat('hh:mm a').format(now);

  final matchingTasks = taskList.where((taskData) {
    final List<bool> frequencyList = taskData['frequency'] != null
        ? List<bool>.from(taskData['frequency'])
        : [];

    final isMatchingWeekday =
        frequencyList.length >= currentWeekday && frequencyList[currentWeekday - 1];
    final isMatchingTime = currentTime.compareTo(taskData['startTime']) >= 0 &&
        currentTime.compareTo(taskData['endTime']) <= 0;

    return isMatchingWeekday && isMatchingTime && taskData['taskstat'] == true;
  }).toList();

  matchingTasks.sort((a, b) {
    if (a['category'] == 'Urgent' && b['category'] != 'Urgent') {
      return -1; // a comes first
    } else if (a['category'] != 'Urgent' && b['category'] == 'Urgent') {
      return 1; // b comes first
    } else {
      return 0; // maintain the same order
    }
  });

  if (matchingTasks.isNotEmpty) {
    showDialog(
      context: context,
      barrierDismissible: matchingTasks[currentTaskIndex]['category'] == 'Urgent' ? false : true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            print('Modal is clicked!');
            playTextForCurrentTask(
              matchingTasks[currentTaskIndex]['taskName'],
              matchingTasks[currentTaskIndex]['description'],
            );
            //Navigator.of(context).pop();
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Tasks for Today',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          title: Text(
                            matchingTasks[currentTaskIndex]['taskName'],
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                matchingTasks[currentTaskIndex]['category'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: matchingTasks[currentTaskIndex]['category'] == 'Urgent'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                matchingTasks[currentTaskIndex]['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 121, 121, 121),
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final List<bool> frequencyList =
                                      matchingTasks[currentTaskIndex]['frequency'] != null
                                          ? List<bool>.from(matchingTasks[currentTaskIndex]['frequency'])
                                          : [];

                                  final bool isFilled =
                                      index < frequencyList.length && frequencyList[index];

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
                              SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: AssetImage('assets/images/task/task.png'),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),

                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (currentTaskIndex > 0)
                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: matchingTasks[currentTaskIndex]['category'] == 'Urgent'
                                      ? null
                                      : () {
                                    setState(() {
                                      currentTaskIndex--;
                                      playTextForCurrentTask(
                                        matchingTasks[currentTaskIndex]['taskName'],
                                        matchingTasks[currentTaskIndex]['description'],
                                      );
                                    });
                                  },
                                ),
                              ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: matchingTasks[currentTaskIndex]['category'] == 'Urgent'
                                  ? null
                                  : () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Spacer(),
                            if (currentTaskIndex < matchingTasks.length - 1)
                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  onPressed: matchingTasks[currentTaskIndex]['category'] == 'Urgent'
                                      ? null
                                      : () {
                                    setState(() {
                                      currentTaskIndex++;
                                      playTextForCurrentTask(
                                        matchingTasks[currentTaskIndex]['taskName'],
                                        matchingTasks[currentTaskIndex]['description'],
                                      );
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    playTextForCurrentTask(
      matchingTasks[currentTaskIndex]['taskName'],
      matchingTasks[currentTaskIndex]['description'],
    );
  }
}



void playTextForCurrentTask(String taskName, String description) async {
  final prefs = await SharedPreferences.getInstance();
  final pGender = prefs.getString('pGender');
  playTextToSpeechParent('The Task for today is $taskName. $description', pGender!);
}


  @override
  Widget build(BuildContext context) {
    //Variables
    final txtTheme = Theme.of(context).textTheme;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark; //Dark mode

    return SafeArea(
      child: Scaffold(
        appBar: DashboardAppBar(isDark: isDark),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDashboardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Top Course
                Text(tDashboardTopCourses, style: txtTheme.headlineMedium?.apply(fontSizeFactor: 1.2)),
                DashboardTopCourses(txtTheme: txtTheme, isDark: isDark),
                const SizedBox(height: tDashboardPadding),

                //Categories
                DashboardCategories(txtTheme: txtTheme),
                //const SizedBox(height: tDashboardPadding),

                GestureDetector(
                  onTap: () {
                    showTaskModal();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 18,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Show Task',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: tDashboardPadding),
                
                //Heading
                Text(tDashboardTitle, style: txtTheme.bodyMedium),
                Text(tDashboardHeading, style: txtTheme.displayMedium),
                //Banners
                DashboardBanners(txtTheme: txtTheme, isDark: isDark),
                const SizedBox(height: tDashboardPadding),

                if (isLoading)
                  CircularProgressIndicator(), // Display loading indicator while fetching data

                /*
                //Categories
                DashboardCategories(txtTheme: txtTheme),
                const SizedBox(height: tDashboardPadding),

                //Search Box
                DashboardSearchBox(txtTheme: txtTheme),
                const SizedBox(height: tDashboardPadding),

                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}





// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}