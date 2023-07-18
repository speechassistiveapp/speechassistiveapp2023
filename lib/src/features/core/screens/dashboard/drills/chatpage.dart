import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import '../../dashboard/drills/assessmentpage.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;


class ChatPage extends StatefulWidget {
  
  final int index; // Add the index parameter
  final String id;
  const ChatPage({Key? key, required this.index,required this.id}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> messages = [];
  bool isSaving = false;
  bool isSaved = false;

  final ScrollController _scrollController = ScrollController();
  final _db = FirebaseFirestore.instance;

  final player = AudioPlayer(); //audio player obj that will play audio
  bool _isLoadingVoice = false; //for the progress indicator
  

  @override
void initState() {
  super.initState();
  initializeFirebase(); // Initialize Firebase here
  retrieveMessagesFromFirestore();
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}

  @override
  void dispose() {
    _scrollController.dispose();
    player.dispose();
    super.dispose();
  }
  

  //For the Text To Speech
  Future<void> playTextToSpeechChild(String text, String gender) async {
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator turn on now
    });

    String voiceId = ''; // Initialize the voiceId variable

    if (gender == 'Male') {
      voiceId = 'ddPMZTVzCv29KTyVkgH7'; // Male voiceId
    } else {
      voiceId = 'Bn1jeLOFNvrZ8OQhgPtc'; // Female voiceId
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
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }
  } //getResponse from Eleven Labs

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
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }
  } //getResponse from Eleven Labs

  @override
  Widget build(BuildContext context) {
  // Determine the current level and instruction based on the number of messages
  int currentLevel = (messages.length ~/ 2) + 1;
  String currentInstruction = getInstructionForLevel(currentLevel);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 109, 168, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 109, 168, 226),
        title:  Text('${widget.id}'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
  padding: const EdgeInsets.all(18.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Align items horizontally center
    crossAxisAlignment: CrossAxisAlignment.start, // Align the second text to the top
    children: [
      Text(
        isSaved && currentLevel == 5 ? 'Start Assessment:' : (currentLevel == 5 ? 'Save the session.' : 'Level $currentLevel:  '),

        
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      if (isSaved)
        SizedBox(width: 30),
      Flexible(
        child: Text(
          currentInstruction,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 219, 219, 219)),
        ),
      ),
      if (isSaved)
        SizedBox(width: 10),
      if (isSaved)
        SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              int index = widget.index;
              // Handle Assessment button click
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssessmentPage(index: index)),
              );
            },
            child: Text('Assessment'),
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(10)), // Adjust the padding as needed
            ),
          ),
        ),
    ],
  ),
),



          Expanded(
  child: Container(
    decoration: friendsBox(),
    child: ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      reverse: false,
      itemBuilder: (context, index) {
        final message = messages[index];
        final levelIndex = (index ~/ 2) + 1;
        final shouldDisplayHorizontalLine = (index % 2 == 0) && (levelIndex >= 1);

        return Column(
      
          children: [
            
            if (shouldDisplayHorizontalLine)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Level $levelIndex',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 213, 213, 213),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
              ),
            FutureBuilder<Widget>(
  future: messagesCard(message),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return snapshot.data!;
    }
  },
)

          ],
        );
      },
    ),
  ),
),


          if (messages.length >= 8 && !isSaving)
            Container(
              color: Colors.white,
              child: saveButton(),
            ),
          if (messages.length < 8)
            Container(
              color: Colors.white,
              child: messageField(
                onSubmit: (message) {
                  addMessage(message);
                },
                messageCount: messages.length,
              ),
            ),
        ],
      ),
    );
  }

  

String getInstructionForLevel(int level) {
  switch (level) {
    case 1:
      return 'Create a conversation prompt that can be answered with a simple "Yes" or "No" response.';
    case 2:
      return 'Create a conversation prompt where the responses can be given using single-word utterances.';
    case 3:
      return 'Create a conversation prompt that contains some phrases.';
    case 4:
      return 'Create a conversation prompt that contains a sentence.';
    default:
      return '';
  }
}

  void addMessage(String message) {
    final time = DateFormat('hh:mm a').format(DateTime.now());
    setState(() {
      messages.add(Message(content: message, time: time));
    });
    // Scroll to the latest message
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<Widget> messagesCard(Message message) async {
    bool check = messages.indexOf(message) % 2 == 0;
    final prefs = await SharedPreferences.getInstance();
    final cAvatar = prefs.getString('cAvatar');
    final pAvatar = prefs.getString('pAvatar');

    //print('Gender Reveal: $pAvatar \n\n $cAvatar');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        
        children: [
  if (check) const Spacer(),
  if (!check)
  _isLoadingVoice
      ? SizedBox(
          width: 65,
          height: 65,
          child: CircularProgressIndicator(),
        )
      : InkWell(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final cGender = prefs.getString('cGender');
            playTextToSpeechChild('${message.content}', cGender!); // Sam voice
          },
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile/${cAvatar}.png'), // Update with the correct image path
            backgroundColor: Colors.transparent,
            radius: 40,
          ),
        ),

  ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 250),
    child: InkWell(
            onTap: () {
              //playTextToSpeech('${message.content}', 'pNInz6obpgDQGcFmaJgB');
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              child: Text(
                '${message.content}',
                style: TextStyle(fontSize: 20, color: check ? Colors.black : Colors.white),
              ),
              decoration: messagesCardStyle(check),
            ),
          ),
  ),
  if (check)
    _isLoadingVoice
        ? SizedBox(
          width: 65,
          height: 65,
          child: CircularProgressIndicator(),
        ) // Show loading indicator
        : InkWell(
            onTap: () async {
              
              final prefs = await SharedPreferences.getInstance();
              final pGender = prefs.getString('pGender');
              playTextToSpeechParent('${message.content}', pGender!);
            },
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile/${pAvatar}.png'), // Update with the correct image path
              backgroundColor: Colors.transparent,
              radius: 40,
            ),
          ),
  if (!check) const Spacer(),
],


      ),
    );
  }

Widget messageField({required Function(String) onSubmit, required int messageCount}) {
  final con = TextEditingController();
  String hintText;
  if (messageCount % 2 == 0) {
    hintText = 'Enter Question';
  } else {
    hintText = 'Enter Answer';
  }
  return Container(
    margin: const EdgeInsets.all(5),
    decoration: messageFieldCardStyle(),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10), // Adjust the vertical padding to change the height
      child: TextField(
        controller: con,
        maxLines: null,
        decoration: messageTextFieldStyle(
          onSubmit: () {
            final message = con.text.trim();
            if (message.isNotEmpty) {
              onSubmit(message);
              con.clear();
            }
          },
          hintText: hintText,
        ),
        style: TextStyle(fontSize: 16), // Adjust the font size if needed
      ),
    ),
  );
}


Widget saveButton() {
    if (isSaving) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Saving...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      if (isSaved) {
        return SizedBox(
          width: double.infinity,
          
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isSaving = true;
              });
              saveMessagesToFirestore().then((_) {
                setState(() {
                  isSaving = false;
                  isSaved = true; // Set isSaved to true after successful save
                });
              });
            },
            child: const Text('Save'),
          ),
        );
      }
    }
  }


Future<void> saveMessagesToFirestore() async {
  // Get the current user's email (replace this with your own logic to get the user's email)
  final prefs = await SharedPreferences.getInstance();
  final currentUserEmail = prefs.getString('email');

  // Create a list of messages to be saved in the itemList
  final List<Map<String, dynamic>> messageList = messages.map((message) => {
    'content': message.content,
    'time': message.time,
  }).toList();

  try {
    final snapshot = await _db.collection('Users').where('Email', isEqualTo: currentUserEmail).get();
    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }
    final documentReference = snapshot.docs.first.reference;

    // Get the existing itemList data
    final existingItemList = await documentReference.get();
    final itemListData = existingItemList.data()?['itemList'] ?? [];

    // Specify the index where you want to save the message list
    final int targetIndex = 0;

    // Merge the current itemList content at the specified index with the messageList
    if (targetIndex < itemListData.length) {
      itemListData[widget.index]['message'] = messageList;
    } else {
      // If the targetIndex is greater than or equal to the itemList length, create a new entry
      final newItem = {
        'date': DateFormat('MMMM d, y h:mm:ss a').format(DateTime.now().toUtc()),
        'name': widget.id,
        'status': false,
        'message': messageList,
      };
      itemListData.add(newItem);
    }

    await documentReference.update({
      'itemList': itemListData,
    });

    Fluttertoast.showToast(
      msg: 'Session saved successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  } catch (e) {
    print('Failed to save messages to itemList in Firestore: $e');

    Fluttertoast.showToast(
      msg: 'Failed to save this session.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}


Future<void> retrieveMessagesFromFirestore() async {
    try {
      // Get the current user's email (replace this with your own logic to get the user's email)
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

      final existingItemList = await documentReference.get();
      final itemListData = existingItemList.data()?['itemList'];

      // Check if the targetIndex is within the bounds of itemListData
      if (itemListData != null && itemListData.length > widget.index) {
        final messageList = itemListData[widget.index]['message'];
        
        
        if (messageList != null) {
          setState(() {
            messages = List<Message>.from(messageList.map(
              (message) => Message(
                content: message['content'],
                time: message['time'],
              ),
              
            ));
            isSaved = true;
          });
        }
      }
    } catch (e) {
      print('Failed to retrieve messages from itemList in Firestore: $e');
    }
  }




  static messagesCardStyle(bool check) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: check ? Colors.grey.shade300 : Color.fromARGB(255, 109, 168, 226),
    );
  }

  static messageFieldCardStyle() {
    return BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color.fromARGB(255, 109, 168, 226)),
        borderRadius: BorderRadius.circular(10));
  }

  static messageTextFieldStyle({required Function() onSubmit, required String hintText}) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      suffixIcon: IconButton(onPressed: onSubmit, icon: const Icon(Icons.send)),
    );
  }

  static friendsBox() {
    return const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)));
  }
}

class Message {
  final String content;
  final String time;

  Message({required this.content, required this.time});
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