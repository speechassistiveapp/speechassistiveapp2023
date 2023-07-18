import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;


class HousePage extends StatefulWidget {
  
  @override
  _HousePageState createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final List<String> _listItem = [
    'assets/images/home/house.png',
    'assets/images/home/living room.png',
    'assets/images/home/nurseryroom.png',
    'assets/images/home/diningroom.png',
    'assets/images/home/kitchen.png',
    'assets/images/home/bathroom.png',
    'assets/images/home/garden.png',
    'assets/images/home/swimmingpool.png',
  ];

  final List<String> _homeNames = [
    'House',
    'Living Room',
    'Nursery Room',
    'Dining Room',
    'Kitchen',
    'Bathroom',
    'Garden',
    'Swimmingpool',
  ];

final List<List<String>> _wordsForHome = [
  ['House', 'It is a House.'],
  ['Living Room', 'It is a Living Room.'],
  ['Nursery Room', 'It is a Nursery Room.'],
  ['Dining Room', 'It is a Dining Room.'],
  ['Kitchen', 'It is a Kitchen.'],
  ['Bathroom', 'It is a Bathroom.'],
  ['Garden', 'It is a Garden.'],
  ['Swimmingpool', 'It is a Swimmingpool.'],
];



final List<List<String>> _emojiWords = [
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
  ['🏡  ', '👨‍👩‍👧‍👦  '],
];


  

  final player = AudioPlayer(); //audio player obj that will play audio
  bool _isLoadingVoice = false; //for the progress indicator

  

  @override
  void dispose() {
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

    // Remove emojis from the text
  final regex = RegExp(
    r'(\ud83c[\udf00-\udfff])|'
    r'(\ud83d[\udc00-\ude4f])|'
    r'(\ud83d[\ude80-\udeff])|'
    r'(\uD83E[\uDD00-\uDDFF])|'
    r'([\u2600-\u27BF])'
  );

  final plainText = text.replaceAll(regex, '');

  // Remove leading spaces before the first word
  final trimmedText = plainText.trimLeft();
    
    
    String transformedText = trimmedText.split(" ").join("   ,");

    print('$transformedText');

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
        "text": transformedText,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }

    

    setState(() {
      _isLoadingVoice = false; //progress indicator turn off now
    });
  } //getResponse from Eleven Labs

void _showImageModal(String imagePath, String colorName, List<String> words, List<String> emojiForWords) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                colorName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: _isLoadingVoice
              ? null
              : () async {
                  final prefs = await SharedPreferences.getInstance();
                  final cGender = prefs.getString('cGender');
                  playTextToSpeechChild('${colorName}', cGender!);
                },
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: words.length,
              itemBuilder: (BuildContext context, int index) {
                final word = words[index];
                final wordemoji = emojiForWords[index];
                return GestureDetector(
                onTap: _isLoadingVoice
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        final cGender = prefs.getString('cGender');
                        playTextToSpeechChild('${word}', cGender!);
                      },
                  child: ListTile(
                    title: Center(
                      child: Text(
                        '$wordemoji $word',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 79, 79, 79),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "All About Colors",
          style: TextStyle(
            color: const Color.fromARGB(255, 29, 29, 29),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: _listItem.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String item = entry.value;
                    final String colorName = _homeNames[index];
                    final List<String> wordsForColor = _wordsForHome[index];
                    final List<String> emojiForWords = _emojiWords[index];
                    return GestureDetector(
                      onTap: () => _showImageModal(item, colorName, wordsForColor,emojiForWords),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(item),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                height: 30,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                child: Center(
                                  child: Text(
                                    colorName,
                                    style: TextStyle(
                                      color: Colors.grey[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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