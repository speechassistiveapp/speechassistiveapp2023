  import 'dart:convert';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter_image_compress/flutter_image_compress.dart';
  import 'package:http/http.dart' as http; 
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:path_provider/path_provider.dart';

    import 'package:flutter/services.dart';
  import 'package:image/image.dart' as img;
  import 'package:shared_preferences/shared_preferences.dart';

  class EditProfileModal extends StatefulWidget {
    @override
    _EditProfileModalState createState() => _EditProfileModalState();
  }

  class _EditProfileModalState extends State<EditProfileModal> {
    // Define controllers for the form fields
    TextEditingController _fullNameController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    // Add more controllers for other form fields if needed

    File? _newAvatarImage; // To store the selected avatar image file

    // Function to pick image from the gallery using image_picker package
    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _newAvatarImage = File(pickedImage.path);
        });
      }
    }

    Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }


  // ...

  Future<void> _uploadImage(File imageFile) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Save the image to a temporary local file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      final newImagePath = '${tempDir.path}/temp_image.jpg';
      await imageFile.copy(tempFile.path);

      // Initialize Firebase
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

      // Remove EXIF data and compress the image
          final compressedImageBytes = await FlutterImageCompress.compressWithFile(
            imageFile.path,
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

      // Open the image to remove EXIF data
      final originalBytes = await tempFile.readAsBytes();
      final originalImage = img.decodeImage(Uint8List.fromList(originalBytes))!;
      final strippedImage = img.copyResize(originalImage, width: originalImage.width, height: originalImage.height);

      // Compress the image
      //final compressedImageBytes = img.encodeJpg(strippedImage, quality: 85);

      // Get the formatted date and time
      final customFormattedDateTime = getCustomFormattedDateTime();

      // Set the image name
      final imageName = 'avatar_${customFormattedDateTime}.jpg';

      // Update the avatar preference key
      prefs.setString('pAvatar', imageName);

      // Make the API request to upload the image
      final response = await http.post(Uri.parse('https://speech-assistive-app.com/api/addprofile.php'),
        body: {
          'image': base64Encode(originalBytes),
          'filename': imageName,
        },
      );
    
      if (response.statusCode == 200) {
        // Update the avatar preference key
      prefs.setString('pAvatar', imageName);

      // Update the avatar value in Firestore
      final userRef = snapshot.docs.first.reference;
      await userRef.update({
        'Avatar': imageName,
      });

        // Image uploaded successfully
        print('Image uploaded');
        _showSnackBar('Image uploaded successfully');
        _closeEditProfileModal();
      } else {
        // Error uploading image
        print('Image upload failed');
        _showSnackBar('Error uploading image');
      }
    } catch (error) {
      print('Error uploading image: $error');
      _showSnackBar('Error uploading image');
    } finally {
      // Hide loading indicator
      Navigator.of(context).pop();
    }
  }

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

    String getCustomFormattedDateTime() {
      final now = DateTime.now();
      final formattedDateTime = "${now.year.toString()}${_addLeadingZero(now.month)}${_addLeadingZero(now.day)}T${_addLeadingZero(now.hour)}${_addLeadingZero(now.minute)}${_addLeadingZero(now.second)}${_addLeadingZero(now.millisecond, size: 3)}";
      return formattedDateTime;
    }

    String _addLeadingZero(int value, {int size = 2}) {
      return value.toString().padLeft(size, '0');
    }

    Future<void> updateUserDetails(String email, String fullName, String password) async {
      // Initialize Firebase
      await initializeFirebase();

      // Access the Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Get the current user's email (replace this with your own logic to get the user's email)
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString('email');

      // Get the user's document reference using their email
      final snapshot = await firestore
          .collection('Users')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        throw 'No user found with the provided email';
      }
  
  final userRef = snapshot.docs.first.reference;
      

      
  
  // Update fields based on whether they are provided or not
  if (fullName.isNotEmpty) {
    await userRef.update({
        'FullName': fullName,
      });
      _showSnackBar('Name updated succesfully!');
      _closeEditProfileModal();
  }
  
  if (password.isNotEmpty) {
    await userRef.update({
        'Password': password,
      });
      _showSnackBar('Password updated succesfully!');
      _closeEditProfileModal();
  }
}

void _closeEditProfileModal() {
  Navigator.pop(context);
}



    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tap the Avatar icon to change your profile picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              //width: 150, // Set the desired width of the avatar
              height: 150, // Set the desired height of the avatar
              child: AspectRatio(
                aspectRatio: 1, // Set the aspect ratio to 1:1
                child: InkWell(
                  onTap: () {
                    // Call the function to pick the image from the gallery
                    _pickImage();
                  },
                  child: SizedBox(
                    height: 50, // Set the fixed height for the Container
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    // Add padding around the ClipOval
                    padding: EdgeInsets.all(8.0),
                    child: _newAvatarImage != null
                        ? ClipOval(
                            child: Image.file(
                              _newAvatarImage!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            Icons.image_search,
                            size: 60,
                          ),
                  ),
                ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Add your form fields here
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            SizedBox(height: 16),
            // Add a password field using TextFormField
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            // Rest of the form fields...
            

            ElevatedButton(
    onPressed: () async {
      // Check if there's a change in full name or password
  final fullName = _fullNameController.text;
  final password = _passwordController.text;
  final prefs = await SharedPreferences.getInstance();
  final currentUserEmail = prefs.getString('email');
  
  if (fullName.isNotEmpty || password.isNotEmpty) {
    await updateUserDetails(currentUserEmail!, fullName, password);
  }

      // Check if there's a new image selected
      if (_newAvatarImage != null) {
        await _uploadImage(_newAvatarImage!);
      }

      
      // You can add more conditions or handle different scenarios as needed
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color.fromARGB(255, 155, 198, 234),
    ),
    child: Text('Update', style: TextStyle(fontSize: 16)),
  ),


            
            SizedBox(height: 10),
          ],
        ),
      );
    }

    void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  }


