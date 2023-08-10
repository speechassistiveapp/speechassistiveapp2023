import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';



class AddObjectPage extends StatefulWidget {
  @override
  _AddObjectPageState createState() => _AddObjectPageState();
}

class _AddObjectPageState extends State<AddObjectPage> {
  List<Map<String, dynamic>> _objectsList = [];// Stores the dynamically added items
  final player = AudioPlayer(); // Audio player object
  bool _isLoadingVoice = false; // For the progress indicator
  bool _isUploading = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}

  // Function to play text as speech
  Future<void> playTextToSpeechChild(String text, String gender) async {
    // Display the loading icon while we wait for the request
    setState(() {
      _isLoadingVoice = true; // Progress indicator turns on now
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
      final bytes = response.bodyBytes; // Get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); // Send the bytes to be read from the JustAudio library
      player.play(); // Play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
    }

    setState(() {
      _isLoadingVoice = false; // Progress indicator turns off now
    });
  }

  // Function to show the modal with object details
void _showObjectModal(String imagePath, String objectName, String objectDescription) {
  final imagePaths = 'https://speech-assistive-app.com/assets/images/addobject/${imagePath}';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0,left: 10.0),
              child: Text(
                '$objectName',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: _isLoadingVoice
                  ? null
                  : () async {
                      final prefs = await SharedPreferences.getInstance();
                      final cGender = prefs.getString('cGender');
                      playTextToSpeechChild('${objectName}', cGender!);
                    },
              child: Image.network(
                // Use the online image URL directly
                imagePaths,
                fit: BoxFit.cover,
                width: 10, // Set an appropriate width for the image
                height: 400, // Set an appropriate height for the image
              ),
            ),
            SizedBox(height: 5.0),
            
           Center(
  child: Padding(
    padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
    child: GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final cGender = prefs.getString('cGender');
        playTextToSpeechChild(objectName, cGender!);
      },
      child: Text(
        '\uD83D\uDCA1 $objectName',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ),
  ),
),
Center(
  child: Padding(
    padding: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
    child: GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final cGender = prefs.getString('cGender');
        playTextToSpeechChild(objectDescription, cGender!);
      },
      child: Text(
        '\uD83D\uDCF7 $objectDescription',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ),
  ),
),



            // Display other details about the object if needed
            // ...
          ],
        ),
      );
    },
  );
}


  
  // Function to add a new object to the list
  void _addNewObject() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final objectInfo = await _showObjectInfoDialog();

      if (objectInfo != null && objectInfo.containsKey('name') && objectInfo.containsKey('description')) {
      final objectName = objectInfo['name'];
      final objectDescription = objectInfo['description'];
        // Get the application's documents directory
        final appDocumentsDir = await getApplicationDocumentsDirectory();

         // Save the image in the assets directory
        final newImageFileName = '${getCustomFormattedDateTime()}_$objectName.png';
        final newImagePath = '${appDocumentsDir.path}/$newImageFileName';
        final File newImageFile = File(pickedImage.path);

       // Remove EXIF data and compress the image
        final compressedImageBytes = await FlutterImageCompress.compressWithFile(
          newImageFile.path,
          quality: 85, // Adjust the quality as needed
        );  

        if (compressedImageBytes != null) {
          await writeToFile(newImagePath, Uint8List.fromList(compressedImageBytes));
          // Rest of the code remains the same
          // Save the object details to Firestore, setState, uploadImageToServer, etc.
        } else {
          // Handle the case when compressedImageBytes is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error compressing image or EXIF data is null.')),
          );
          print('Error compressing image or EXIF data is null.');
          return; // Return from the function without proceeding further
        }

        // Save the object details to Firestore
        await saveObjectToFirestore(
          objectName: objectName,
          objectDescription: objectDescription,
          newImagePath: newImageFileName,
          status: true,
        );

        setState(() {
          _isUploading = true;
        });
        // Save the image to the server using the PHP API
        try {
          await uploadImageToServer(newImagePath, newImageFileName);
        } catch (e) {
          // Show a success message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          print('Error uploading image: $e');
        }

        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Widget _buildLoadingModal() {
  return Stack(
    children: [
      ModalBarrier(
        dismissible: false,
        color: Colors.black54,
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Text(
              "Uploading Image, please wait...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ],
  );
}


  Future<void> saveObjectToFirestore({
  required String? objectName,
  required String? objectDescription,
  required String? newImagePath,
  required bool? status,
}) async {
  try {
    // Initialize Firebase once at the start of your app
    await initializeFirebase();

    // Access the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the current user's email (replace this with your own logic to get the user's email)
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');

    // Get the user's document reference using their email
    final snapshot = await firestore
        .collection('Users')
        .where('Email', isEqualTo: currentUserEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final documentReference = snapshot.docs.first.reference;

    // Create a new entry with the object details
    final newEntry = {
      'objectName': objectName,
      'objectDescription': objectDescription,
      'imagePath': newImagePath,
      'status': status,
    };

    // Update the 'objectsList' field using array union to add the new entry
    await documentReference.update({
      'objectsList': FieldValue.arrayUnion([newEntry]),
    });

    // Show a success message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Object saved successfully!')),
    );
  } catch (e) {
    // Show an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save object: $e')),
    );
  }
}

// Function to retrieve specific object data from Firestore based on imagepathname
Future<Map<String, dynamic>> fetchObjectByImagePath(String imagepathname) async {
  try {
    // Initialize Firebase once at the start of your app
    await initializeFirebase();

    // Access the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the current user's email (replace this with your own logic to get the user's email)
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');

    // Get the user's document reference using their email
    final snapshot = await firestore
        .collection('Users')
        .where('Email', isEqualTo: currentUserEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final documentReference = snapshot.docs.first.reference;

    // Get the user's data from Firestore
    final documentSnapshot = await documentReference.get();

    // Get the 'objectsList' field from the document
    final objectsList = documentSnapshot.get('objectsList') as List<dynamic>;

    // Convert the list of objects to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> objects = objectsList.cast<Map<String, dynamic>>();

    // Find the object with the matching imagepathname
    final specificObject = objects.firstWhere((object) => object['imagePath'] == imagepathname, orElse: () => {});

    return specificObject;
  } catch (e) {
    throw Exception('Error fetching specific object: $e');
  }
}

Future<void> _changeObjectStatus(String imagePath) async {
  try {
    // Initialize Firebase once at the start of your app
    await initializeFirebase();

    // Access the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Get the current user's email (replace this with your own logic to get the user's email)
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = prefs.getString('email');

    // Get the user's document reference using their email
    final snapshot = await firestore
        .collection('Users')
        .where('Email', isEqualTo: currentUserEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final documentReference = snapshot.docs.first.reference;

    // Get the user's data from Firestore
    final documentSnapshot = await documentReference.get();

    // Get the 'objectsList' field from the document
    final objectsList = documentSnapshot.get('objectsList') as List<dynamic>;

    // Convert the list of objects to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> objects = objectsList.cast<Map<String, dynamic>>();

    // Find the object with the matching imagePath
    final specificObjectIndex = objects.indexWhere((object) => object['imagePath'] == imagePath);

    if (specificObjectIndex != -1) {
      // Update the 'status' field of the specific object to false
      objects[specificObjectIndex]['status'] = false;
      // Update the 'objectsList' field with the updated objects list
      await documentReference.update({
        'objectsList': objects,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Object status updated successfully!')),
      );
    } else {
      throw 'No object found with the provided imagePath';
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update object status: $e')),
    );
  }
}





  Future<bool> isUrlActive(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> uploadImageToServer(String imagePath, String newImageFileName) async {
    String url = 'https://speech-assistive-app.com/api/addobject.php';
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Check if the URL is active before proceeding
    if (await isUrlActive(url)) {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64Image,
          'filename': newImageFileName,
        },
      );
      if (response.statusCode == 200) {
        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully.')),
        );
        print('Image uploaded successfully.');
      } else {
        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Error: ${response.statusCode}')),
        );
        print('Failed to upload image. Error: ${response.statusCode}');
      }
    } catch (e) {
        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      print('Error uploading image: $e');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL is not active. Please check the URL.')),
    );
    print('URL is not active. Please check the URL.');
  }
}


  String getCustomFormattedDateTime() {
    final now = DateTime.now();
    final formattedDateTime = "${now.year.toString()}${_addLeadingZero(now.month)}${_addLeadingZero(now.day)}T${_addLeadingZero(now.hour)}${_addLeadingZero(now.minute)}${_addLeadingZero(now.second)}${_addLeadingZero(now.millisecond, size: 3)}";
    return formattedDateTime;
  }

  String _addLeadingZero(int value, {int size = 2}) {
    return value.toString().padLeft(size, '0');
  }


  // Function to write ByteData to a file
  // Update the writeToFile function
  Future<void> writeToFile(String path, List<int> bytes) async {
    final ByteData data = ByteData.sublistView(Uint8List.fromList(bytes));
    await writeDataToFile(path, data);
  }

  // Helper function to write data to file using rootBundle
  Future<void> writeDataToFile(String path, ByteData data) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

Future<Map<String, String?>> _showObjectInfoDialog() {
  String? objectName;
  String? objectDescription;
  Completer<Map<String, String?>> completer = Completer<Map<String, String?>>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Enter Object Information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                objectName = value;
              },
              decoration: InputDecoration(labelText: 'Object Name'),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                objectDescription = value;
              },
              decoration: InputDecoration(labelText: 'Object Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              completer.complete({'name': objectName, 'description': objectDescription});
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );

  return completer.future;
}




   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Add Object Page",
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
          child: FutureBuilder<List<String>>(
            future: _fetchSavedImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error fetching images"),
                );
              } else if (snapshot.hasData) {
                List<String> imagePaths = snapshot.data!;
                return ListView.builder(
  itemCount: imagePaths.length,
  itemBuilder: (context, index) {
    final String imagePath = 'https://speech-assistive-app.com/assets/images/addobject/${imagePaths[index]}';
    final objectName = "Object ${index + 1}";
    final objectDescription = "Description for Object ${index + 1}";

    // Call the asynchronous function to fetch the specific object data
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchObjectByImagePath('${imagePaths[index]}'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error fetching specific object: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final specificObject = snapshot.data!;
          final objectName = specificObject['objectName'];
          final objectDescription = specificObject['objectDescription'];
          final objectStatus = specificObject['status'];

          // Only show the card if the object status is true
          if (objectStatus == true) {
            return GestureDetector(
              onTap: () {
                _showObjectModal(imagePaths[index], objectName, objectDescription); // Pass the imagePath here
              },
              child: Card(
                child: ListTile(
                  title: Text(objectName),
                  subtitle: Text(objectDescription + '$objectStatus'),
                  leading: Image.network(
                    // Display the image using the URL
                    imagePath,
                    width: 50,
                    height: 50,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _changeObjectStatus(imagePaths[index]);
                      setState(() {}); // Reload the list after updating the status
                    },
                  ),
                ),
              ),
            );
          } else {
            // If the status is false, return an empty Container
            return Container();
          }
        } else {
          // Handle the case when there is no data
          return Container(); // Empty container if there are no images
        }
      },
    );
  },
);

              } else {
                return Container(); // Empty container if there are no images
              }
            },
          ),
        ),
      ],
    ),
  ),
),

      floatingActionButton: Stack(
      children: [
        FloatingActionButton(
          onPressed: _addNewObject,
          child: Icon(Icons.add),
        ),
        if (_isUploading) _buildLoadingModal(), // Show loading modal if _isUploading is true
      ],
    ),
    );
  }
}



Future<List<String>> _fetchSavedImages() async {
  final url = 'https://speech-assistive-app.com/api/addobject_retrieve.php'; // Replace with the actual URL of your PHP script

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> imageFiles = json.decode(response.body);
      // Convert the dynamic list to List<String>
      final List<String> imagePaths = imageFiles.map((file) => file.toString()).toList();
      return imagePaths;
    } else {
      throw Exception('Failed to fetch images');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}


bool _isImageFile(File file) {
  final List<String> validImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
  final String extension = file.path.split('.').last.toLowerCase();
  return validImageExtensions.contains(extension);
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
