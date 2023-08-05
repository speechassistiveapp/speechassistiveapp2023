import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;


class ColorsPage extends StatefulWidget {
  @override
  _ColorsPageState createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> {
  final List<String> _listItem = [
    'assets/images/colors/blue.png',
    'assets/images/colors/green.png',
    'assets/images/colors/yellow.png',
    'assets/images/colors/orange.png',
    'assets/images/colors/red.png',
    'assets/images/colors/pink.png',
    'assets/images/colors/purple.png',
    'assets/images/colors/brown.png',
    'assets/images/colors/grey.png',
    'assets/images/colors/black.png',
    'assets/images/colors/white.png',
  ];

  final List<String> _colorNames = [
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Red',
    'Pink',
    'Purple',
    'Brown',
    'Grey',
    'Black',
    'White',
  ];

final List<List<String>> _wordsForColors = [
  ['Color Blue', 'This is a Blue Bird.'],
  ['Color Green', 'This is a Green Broccoli.'],
  ['Color Yellow', 'This is a Yellow Banana.'],
  ['Color Orange', 'This is an Orange Tiger.'],
  ['Color Red', 'This is a Red Strawberry.'],
  ['Color Pink', 'This is a Pink Flamingo.'],
  ['Color Purple', 'This is a Purple Grapes.'],
  ['Color Brown', 'This is a Brown Puppy.'],
  ['Color Grey', 'This is a Grey Mouse.'],
  ['Color Black', 'This is a Black Shoes.'],
  ['Color White', 'This is a White Cat.'],
];


final List<List<String>> _emojiWords = [
  ['🔵  ', '💙  '],
  ['🟩  ', '🥦  '],
  ['🟡  ', '🍌  '],
  ['🔶  ', '🐯  '],
  ['⭕  ', '🍓  '],
  ['🧠  ', '🦩  '],
  ['💜  ', '🍇  '],
  ['🤎  ', '🐶  '],
  ['👽  ', '🐭  '],
  ['🖤  ', '⚫  '],
  ['🤍  ', '⚪  '],
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
               child: CachedNetworkImage(
                imageUrl: 'https://speech-assistive-app.com/assets/images/colors/${colorName}.png',
                fit: BoxFit.cover,
                placeholder: (context, url) => LinearProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
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
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _fetchDataFromFirestore(), // Call the function to fetch data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else {
                      // Data retrieved successfully
                      final List<Map<String, dynamic>> itemList =
                          List<Map<String, dynamic>>.from(snapshot.data!['itemList']);
                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: itemList.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final Map<String, dynamic> item = entry.value;
                          final String itemImagePath = _listItem[index];
                          final String colorName = item['_Names'];
                          final String description = item['_Home'];
                          final String emoji1 = item['_emojiWords1'];
                          final String emoji2 = item['_emojiWords2'];

                          final List<String> wordsForColor = [colorName, description];
                          final List<String> emojiForWords = [emoji1, emoji2];

                          final String imagePath =
                              'https://speech-assistive-app.com/assets/images/colors/${colorName}.png';


                          return GestureDetector(
                            onTap: () => _showImageModal(itemImagePath, colorName, wordsForColor, emojiForWords),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(imagePath), // Use NetworkImage with imagePath
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
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>> _fetchDataFromFirestore() async {
    try {
      // Access the Firebase Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // The collection name and document ID from where you want to fetch data
      final CollectionReference<Map<String, dynamic>> collectionRef =
          firestore.collection('Assets');
      final DocumentReference<Map<String, dynamic>> documentRef =
          collectionRef.doc('colorpage');

      // Fetch the document snapshot
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await documentRef.get();

      return snapshot;
    } catch (e) {
      // Handle any errors that occurred during the process
      print('Error fetching data from Firestore: $e');
      throw e;
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