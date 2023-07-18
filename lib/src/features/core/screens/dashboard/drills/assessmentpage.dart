import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/drills/mic_recorder.dart';
import 'package:leopard_flutter/leopard.dart';
import 'package:leopard_flutter/leopard_error.dart';
import 'package:leopard_flutter/leopard_transcript.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../../../repository/user_repository/user_repository.dart';
import '../drills/assessmentscreen.dart';

class AssessmentPage extends StatefulWidget {
  final int index;

  AssessmentPage({required this.index});
  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<String> _listItem = [
    'assets/images/levelimg/one.png',
    'assets/images/levelimg/two.png',
    'assets/images/levelimg/three.png',
    'assets/images/levelimg/four.png',
  ];

  final List<String> _levelList = [
    "Yes or No",
    "Utterance",
    "Phrases",
    "Sentence",
  ];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<List<bool>> _isLockedStream;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _isLockedStream = retrieveIsLockedFromFirestore();
    retrieveMessagesListFromFirestore();
  }

  Stream<List<bool>> retrieveIsLockedFromFirestore() async* {
  try {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');

    final snapshots = _db
        .collection('Users')
        .where('Email', isEqualTo: currentUserEmail)
        .snapshots();

    await for (final snapshot in snapshots) {
      final itemListData = snapshot.docs.isNotEmpty ? snapshot.docs.first.data()['itemList'] : null;

      if (itemListData != null && itemListData.length > widget.index) {
        final isLockedList = itemListData[widget.index]['isLocked'];

        if (isLockedList != null) {
          yield List<bool>.from(isLockedList);
        }
      }
    }

    yield List<bool>.filled(_listItem.length, true);
  } catch (e) {
    print('Failed to retrieve isLocked data from itemList in Firestore: $e');
    yield List<bool>.filled(_listItem.length, true);
  }
}


  Future<List<Message>> retrieveMessagesListFromFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('email');

      final snapshot = await _db
          .collection('Users')
          .where('Email', isEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isEmpty) {
        throw 'No user found with the provided email';
      }

      final documentReference = snapshot.docs.first.reference;

      final userData = await documentReference.get();
      final itemListData = userData.data()?['itemList'];

      if (itemListData != null && itemListData.length > widget.index) {
        final messagesList = itemListData[widget.index]['message'];

        if (messagesList != null) {
          messages = List<Message>.from(messagesList.map(
            (message) => Message(
              content: message['content'],
              time: message['time'],
            ),
          ));

          print('Retrieved Messages:');
          for (var message in messages) {
            print('Content: ${message.content}, Time: ${message.time}');
          }

          return messages;
        }
      }

      return [];
    } catch (e) {
      print('Failed to retrieve messagesList from itemList in Firestore: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Assessment",
          style: TextStyle(
            color: const Color.fromARGB(255, 29, 29, 29),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                StreamBuilder<List<bool>>(
                  stream: _isLockedStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final _isLocked = snapshot.data!;
                      return Column(
                        children: [
                          for (int i = 0; i < _listItem.length; i++)
                            GestureDetector(
                              onTap: () {
                                if (_isLocked.isEmpty || _isLocked[i]) {
                                  // Handle locked container tapped
                                  // You can add your logic here, such as showing a dialog or unlocking the container
                                  return;
                                }

                                // Handle unlocked container tapped
                                // You can navigate to the assessment screen or perform any other action
                                // Here, we navigate to the assessment screen by pushing a new route
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssessmentScreen(
                                      index: widget.index,
                                      level: i,
                                      messages: messages,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                margin: EdgeInsets.only(bottom: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage(_listItem[i]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomRight,
                                      colors: [
                                        _isLocked.isEmpty || _isLocked[i]
                                            ? Colors.black.withOpacity(0.8) // Increase opacity for locked containers
                                            : Colors.black.withOpacity(0.2),
                                        _isLocked.isEmpty || _isLocked[i]
                                            ? Colors.black.withOpacity(0.6) // Increase opacity for locked containers
                                            : Colors.black.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        _levelList[i],
                                        style: TextStyle(
                                          color: _isLocked.isEmpty || _isLocked[i]
                                              ? Colors.grey // Set disabled color for locked container
                                              : const Color.fromARGB(255, 255, 255, 255),
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        margin: EdgeInsets.symmetric(horizontal: 40),
                                        child: Center(
                                          child: Text(
                                            _isLocked.isEmpty || _isLocked[i]
                                                ? "Level ${i + 1} Locked"
                                                : "Level ${i + 1}",
                                            style: TextStyle(
                                              color: _isLocked.isEmpty || _isLocked[i]
                                                  ? Colors.grey // Set disabled color for locked container
                                                  : const Color.fromARGB(255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Message {
  final String content;
  final String time;

  Message({required this.content, required this.time});
}
