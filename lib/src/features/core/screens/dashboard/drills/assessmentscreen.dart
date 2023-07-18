import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:leopard_flutter/leopard.dart';
import 'package:leopard_flutter/leopard_error.dart';
import 'package:leopard_flutter/leopard_transcript.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/drills/mic_recorder.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:number_to_words_english/number_to_words_english.dart';

import 'package:confetti/confetti.dart';

import '../../dashboard/drills/assessmentpage.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class AssessmentScreen extends StatefulWidget {
  final int index;
  final int level;
  final List<Message> messages;

  AssessmentScreen({Key? key, required this.index, required this.level, required this.messages})
      : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}


class _AssessmentScreenState extends State<AssessmentScreen> {
  // Create a confetti controller
  ConfettiController _confettiController = ConfettiController();
  final String accessKey =
      'CGhMYCkGekIOdp23RnnqdhPktogV/jPwSNIgOP5yVq6mRDSSyKYIpg==';
  final int maxRecordingLengthSecs = 120;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isError = false;
  String errorMessage = "";

  bool isButtonDisabled = false;
  bool isRecording = false;
  bool isProcessing = false;
  double recordedLength = 0.0;
  String statusAreaText = "";
  String transcriptText = "";
  List<LeopardWord> words = [];

  MicRecorder? _micRecorder;
  Leopard? _leopard;
  String? pAvatar; // Define pAvatar variable
  String? cAvatar; // Define pAvatar variable

  List<Message> displayedMessages = [];
  int score = 0;

  String congPath = "";
  

    // Generate a random number between 0 and 4
    Random random = Random();
  

  final player = AudioPlayer(); //audio player obj that will play audio
  bool _isLoadingVoice = false; //for the progress indicator

  @override
  void initState() {
    super.initState();
    setState(() {
      isButtonDisabled = true;
      recordedLength = 0.0;
      statusAreaText = "Initializing Leopard...";
      transcriptText = "";
      words = [];
    });

    initLeopard();
    initAvatar(); // Initialize pAvatar
  }

  

  // Initialize pAvatar from shared preferences
  Future<void> initAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pAvatar = prefs.getString('pAvatar');
      cAvatar = prefs.getString('cAvatar');
    });
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
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }
  } //getResponse from Eleven Labs

Widget buildMessagesArea() {
  if (widget.level == 0) {
    displayedMessages = widget.messages.take(2).toList();
  } else if (widget.level >= 1 && widget.level <= 3) {
    int startIndex = (widget.level - 1) * 2 + 2;
    int endIndex = startIndex + 2;
    displayedMessages = widget.messages.sublist(startIndex, endIndex);
  } else if (widget.level >= 4) {
    int startIndex = (widget.level - 1) * 2;
    int endIndex = startIndex + 2;
    displayedMessages = widget.messages.sublist(startIndex, endIndex);
  }

  return Expanded(
    flex: 2,
    child: SizedBox(
      width: 300, // Adjust width here
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
              final pGender = prefs.getString('pGender');
              playTextToSpeechParent('${displayedMessages[0].content}', pGender!);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5), // Adjust opacity here
            borderRadius: BorderRadius.circular(10), // Adjust border radius here
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2), // Shadow offset
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundImage: pAvatar != null
                      ? AssetImage('assets/images/profile/$pAvatar.png')
                      : AssetImage('assets/images/profile/profile-pic.png'),
                  backgroundColor: Colors.transparent,
                  radius: 60,
                ),
                SizedBox(height: 10),
                Text(
                  "${displayedMessages.isNotEmpty ? displayedMessages[0].content : ''}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


Widget buildInstruction() {
  String instructionText = '';

  switch (widget.level) {
    case 0:
      instructionText = 'Can be answered with a simple \n "Yes" or "No" response.';
      break;
    case 1:
      instructionText = 'The responses can be given \n using single-word utterances.';
      break;
    case 2:
      instructionText = 'Contains some phrases.';
      break;
    case 3:
      instructionText = 'Contains a sentence.';
      break;
    default:
      instructionText = 'Default instruction.';
  }

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      instructionText,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  );
}


Widget buildStar(bool isFilled) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 0), // Adjust the offset if needed
            ),
          ],
        ),
      ),
      GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.amber.withOpacity(0.9),
        child: Icon(
          Icons.star,
          size: 60,
          color: isFilled ? Colors.amber : Colors.grey,
        ),
      ),
    ],
  );
}

@override
void dispose() {
  cleanupLeopard();
  _confettiController.dispose();
  player.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Level ${widget.level +1 }",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
      children: [
        Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/pattern.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.08), BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: Column(
            children: [
            //Text("Assessment for Level ${widget.level}"),
            SizedBox(height: 20.0),
            buildInstruction(),
            SizedBox(height: 20.0),
            buildMessagesArea(),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: buildStar(score >= 1),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: buildStar(score >= 2),
                ),
                Padding(
                  padding: EdgeInsets.zero, // No spacing on the last star
                  child: buildStar(score >= 3),
                ),
              ],
            ),

            //buildLeopardTextArea(context),
            //buildLeopardWordArea(context),
            //buildErrorMessage(context),
            buildLeopardStatusArea(context),
            buildStartButton(context),
            
            SizedBox(height: 20.0),
                //footer
            ],
          ),
        ),
      ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.1,
            numberOfParticles: 10,
            gravity: 0.2,
            shouldLoop: false,
            colors: [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    ),
    );
  }

  Color picoBlue = Color.fromRGBO(55, 125, 255, 1);

Widget buildStartButton(BuildContext context) {
  return Expanded(
    flex: 1,
    child: Container(
      width: 120, // Adjust width to match image size
      height: 40, // Adjust height to match image size
      decoration: BoxDecoration(
        image: cAvatar != null
            ? DecorationImage(
                image: AssetImage('assets/images/profile/$cAvatar.png'),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: (isButtonDisabled || isError)
                ? null
                : isRecording
                    ? _stopRecording
                    : _startRecording,
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(0, 255, 255, 255),
              side: BorderSide.none,
              textStyle: TextStyle(color: Colors.white),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Container(),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Center(
                child: Icon(
                  isRecording ? Icons.mic_off : Icons.mic,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  
  buildLeopardTextArea(BuildContext context) {
    return Expanded(
        flex: 6,
        child: Container(
            alignment: Alignment.topCenter,
            color: Color(0xff25187e),
            margin: EdgeInsets.all(10),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(10),
                physics: RangeMaintainingScrollPhysics(),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      transcriptText,
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )))));
  }

  

  buildLeopardWordArea(BuildContext context) {
    List<TableRow> tableRows = words.map<TableRow>((leopardWord) {
      return TableRow(children: [
        Column(children: [
          Text(leopardWord.word, style: TextStyle(color: Colors.white))
        ]),
        Column(children: [
          Text('${leopardWord.startSec.toStringAsFixed(2)}s',
              style: TextStyle(color: Colors.white))
        ]),
        Column(children: [
          Text('${leopardWord.endSec.toStringAsFixed(2)}s',
              style: TextStyle(color: Colors.white))
        ]),
        Column(children: [
          Text('${(leopardWord.confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white))
        ]),
      ]);
    }).toList();

    return Expanded(
        flex: 4,
        child: Container(
          color: Color(0xff25187e),
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(10),
          child: Column(children: [
            Container(
                color: Colors.white,
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: Table(children: [
                  TableRow(children: [
                    Column(children: [Text("Word")]),
                    Column(children: [Text("Start")]),
                    Column(children: [Text("End")]),
                    Column(children: [Text("Confidence")]),
                  ])
                ])),
            Flexible(
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(10),
                    physics: RangeMaintainingScrollPhysics(),
                    child: Table(children: tableRows)))
          ]),
        ));
  }

buildLeopardStatusArea(BuildContext context) {
  return Expanded(
    flex: 1,
    child: Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        statusAreaText,
        style: TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
    ),
  );
}


  buildErrorMessage(BuildContext context) {
    return Expanded(
        flex: isError ? 4 : 0,
        child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 20, right: 20),
            padding: EdgeInsets.all(5),
            decoration: !isError
                ? null
                : BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(5)),
            child: !isError
                ? null
                : Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )));
  }

  Widget footer = Expanded(
      flex: 1,
      child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 20),
          margin: EdgeInsets.only(top: 10),
          child: const Text(
            "Made in Vancouver, Canada by Picovoice",
            style: TextStyle(color: Color(0xff666666)),
          )));

  Future<void> initLeopard() async {
    final String modelPath = "assets/testing.pv";

    try {
      _leopard = await Leopard.create(accessKey, modelPath,
          enableAutomaticPunctuation: true);
      _micRecorder = await MicRecorder.create(
          _leopard!.sampleRate, recordedCallback, errorCallback);
      setState(() {
        statusAreaText =
            "Press avatar to start recording.";
        isButtonDisabled = false;
      });
    } on LeopardInvalidArgumentException catch (ex) {
      errorCallback(LeopardInvalidArgumentException(
          "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
    } on LeopardActivationException {
      errorCallback(
          LeopardActivationException("AccessKey activation error."));
    } on LeopardActivationLimitException {
      errorCallback(LeopardActivationLimitException(
          "AccessKey reached its device limit."));
    } on LeopardActivationRefusedException {
      errorCallback(LeopardActivationRefusedException("AccessKey refused."));
    } on LeopardActivationThrottledException {
      errorCallback(
          LeopardActivationThrottledException("AccessKey has been throttled."));
    } on LeopardException catch (ex) {
      errorCallback(ex);
    }
  }

  Future<void> recordedCallback(double length) async {
    if (length < maxRecordingLengthSecs) {
      setState(() {
        recordedLength = length;
        statusAreaText =
            "Recording: ${length.toStringAsFixed(1)} / $maxRecordingLengthSecs seconds";
      });
    } else {
      setState(() {
        isButtonDisabled = true;
        recordedLength = length;
        statusAreaText = "Transcribing, please wait...";
      });
      await _stopRecording();
    }
  }

  void errorCallback(LeopardException error) {
    setState(() {
      isError = true;
      errorMessage = error.message!;
    });
  }

  Future<void> _startRecording() async {
    if (isRecording || _micRecorder == null) {
      return;
    }

    try {
      await _micRecorder!.startRecord();
      setState(() {
        isRecording = true;
      });
    } on LeopardException catch (ex) {
      print("Failed to start audio capture: ${ex.message}");
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording || _micRecorder == null) {
      return;
    }

    try {
      File recordedFile = await _micRecorder!.stopRecord();
      setState(() {
        statusAreaText = "Transcribing, please wait...";
        isRecording = false;
        isButtonDisabled = true;
      });
      _processAudio(recordedFile);
    } on LeopardException catch (ex) {
      print("Failed to stop audio capture: ${ex.message}");
    }
  }

  void cleanupLeopard() {
  _leopard?.delete();
  _micRecorder?.delete();
}


  Future<void> _processAudio(File recordedFile) async {
    if (_leopard == null) {
      return;
    }

    Stopwatch stopwatch = Stopwatch()..start();
    LeopardTranscript? result = await _leopard?.processFile(recordedFile.path);
    Duration elapsed = stopwatch.elapsed;

    String audioLength = recordedLength.toStringAsFixed(1);
    String transcriptionTime =
        (elapsed.inMilliseconds / 1000).toStringAsFixed(1);

    int randomNumber = random.nextInt(5); // Generates a number from 0 to 4 (inclusive)

    // Construct the image path based on the random number
    congPath = "assets/images/congrats/congratulations$randomNumber.png";
    
    setState(() {
      statusAreaText =
          "Transcribed $audioLength(s) of audio in $transcriptionTime(s)";
      transcriptText = result?.transcript ?? "";
      words = result?.words ?? [];
      isButtonDisabled = false;
    });

    bool isCorrect = false;

    if (transcriptText.isNotEmpty && displayedMessages.length > 1) {
      String expectedResponse = displayedMessages[1].content.toLowerCase();
      String actualResponse = transcriptText.toLowerCase();
      // Convert numbers to words in expected response
      expectedResponse = expectedResponse.replaceAllMapped(
        RegExp(r'\d+'),
        (match) => NumberToWordsEnglish.convert(int.parse(match.group(0)!)),
      );

      isCorrect = actualResponse.contains(expectedResponse);

      

      print('$expectedResponse - $actualResponse');
      print('$isCorrect');

      if (isCorrect) {
        setState(() {
          score++;
        });
        

        // Trigger confetti effect
        _confettiController.play();
        Timer(Duration(seconds: 5), () {
          _confettiController.stop();
        });
        expectedResponse = '';
        actualResponse = '';
        isCorrect = false;

        

        if (score == 3) {
          _showLevelUpDialog();
        }
      }
    }
  }

  void _showLevelUpDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Congratulations!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 10),
              Text("You have completed Level ${widget.level + 1}.",
              style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,),
              SizedBox(height: 10),
              Image.asset(
                congPath, // Replace with the path to your image
                height: 200, // Adjust the height as needed
              ),
              SizedBox(height: 10),
              Text("Are you ready to take on \n Level ${widget.level + 2}?",
              style: TextStyle(
                  fontSize: 19,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                score = 0;
              });
              // Close the dialog
              Navigator.of(context).pop();
            },
            child: Text("Not Yet"),
          ),
          TextButton(
            onPressed: () async {
              // Update isLocked in Firebase Firestore
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
                  itemListData[widget.index]['isLocked'] = List.generate(
                      itemListData[widget.index]['isLocked'].length,
                      (index) => index == widget.level + 1 ? false : itemListData[widget.index]['isLocked'][index]);

                  await documentReference.update({'itemList': itemListData});
                }
              } catch (e) {
                print('Failed to update isLocked data in Firestore: $e');
              }
              
              // Close the dialog
              Navigator.of(context).pop();
              Get.snackbar("Next", 'Return to Level Menu!', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
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