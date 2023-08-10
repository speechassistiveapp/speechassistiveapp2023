import 'package:flutter/material.dart';
import 'package:login_flutter_app/src/constants/image_strings.dart';
import 'package:login_flutter_app/src/constants/sizes.dart';
import 'package:login_flutter_app/src/constants/text_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../common_widgets/form/form_header_widget.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

  import 'package:firebase_core/firebase_core.dart';

class ForgetPasswordMailScreen extends StatefulWidget {
  const ForgetPasswordMailScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordMailScreenState createState() =>
      _ForgetPasswordMailScreenState();
}

class _ForgetPasswordMailScreenState extends State<ForgetPasswordMailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isSendingOTP = false;
  bool _otpSentSuccessfully = false;
  bool _emailExists = false;
  bool _isOTPVerified = false;
  late String sentOTP;

  Future<void> verifyEmailAndSendOTP(String recipientEmail) async {
    setState(() {
      _isSendingOTP = true;
    });

    final username = 'speechassistiveapp@gmail.com';
    final password = 'kyrmrkkfylzltjgt';

    final smtpServer = gmail(username, password);

    final random = Random();
    final otp = '${100000 + random.nextInt(900000)}';
    sentOTP = otp;

    final message = Message()
      ..from = Address(username, 'Speech Assistive App')
      ..recipients.add(recipientEmail)
      ..subject = 'Speech Assistive App OTP Code Request'
      ..text = 'Your OTP code is: $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');

      setState(() {
        _isSendingOTP = false;
        _otpSentSuccessfully = true;
      });
    } catch (e) {
      print('Error sending OTP: $e');
      setState(() {
        _isSendingOTP = false;
        _otpSentSuccessfully = false;
      });
    }
  }

  Future<void> checkEmailExistence(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('Email', isEqualTo: email)
        .get();

    setState(() {
      _emailExists = snapshot.docs.isNotEmpty;
    });

    if (_emailExists) {
      verifyEmailAndSendOTP(email);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Email Not Found'),
            content: Text('The provided email does not exist.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void verifyOTP(String inputOTP, String sentOTP) {
    setState(() {
      _isOTPVerified = inputOTP == sentOTP;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDark = brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSize),
            child: Column(
              children: [
                FormHeaderWidget(
                  image: tForgetPasswordImage,
                  title: tForgetPassword,
                  subTitle: tForgetPasswordSubTitle,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  heightBetween: 30.0,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: tFormHeight),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: tEmail,
                          hintText: tEmail,
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'OTP',
                          hintText: 'Enter OTP',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        controller: _otpController,
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSendingOTP
                                  ? null
                                  : () {
                                      final email = _emailController.text;
                                      if (email.isNotEmpty) {
                                        checkEmailExistence(email);
                                      }
                                    },
                              child: _isSendingOTP
                                  ? CircularProgressIndicator()
                                  : _otpSentSuccessfully
                                      ? Text('Resend OTP')
                                      : Text('Send OTP'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isOTPVerified
                                  ? () {
                                      if (_otpController.text.isEmpty) {
                                        _showEmptyOTPWarning();
                                      }  else if (_isOTPVerified) {
                                        _showChangePasswordDialog(_emailController.text);
                                      } else {
                                        _showIncorrectOTPWarning();
                                      }
                                    }
                                  : () {
                                      final inputOTP = _otpController.text;
                                      if (inputOTP.isNotEmpty) {
                                        if(inputOTP == sentOTP)
                                        {
                                          verifyOTP(inputOTP, sentOTP);
                                          _showChangePasswordDialog(_emailController.text);
                                        }else{
                                          _showIncorrectOTPWarning();
                                        }
                                        
                                      }else if (inputOTP.isEmpty) {
                                        _showEmptyOTPWarning();
                                      }else{
                                        _showIncorrectOTPWarning();
                                      }
                                    },
                              child: const Text(tNext),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIncorrectOTPWarning() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Warning'),
        content: Text('The entered OTP is incorrect. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  void _showEmptyOTPWarning() {
  showDialog(
    context: context,
    builder: (context) {
      _isOTPVerified = false;
      return AlertDialog(
        title: Text('Warning'),
        content: Text('Please enter the OTP code.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }


  void _showChangePasswordDialog(String email) {
  showDialog(
    context: context,
    builder: (context) {
      _isOTPVerified = false;
      String newPassword = '';
      String confirmPassword = '';

      return AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Add spacing
              child: TextField(
              decoration: InputDecoration(labelText: 'New Password'),
              onChanged: (value) {
                newPassword = value;
              },
            ),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Confirm Password'),
              onChanged: (value) {
                confirmPassword = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (newPassword.isNotEmpty && confirmPassword.isNotEmpty && newPassword == confirmPassword) {
                // TODO: Update the password and navigate to the next step

                try {
                  // Initialize Firebase
                  await initializeFirebase();

                  // Access the Firestore instance
                  final firestore = FirebaseFirestore.instance;

                  // Get the current user's email from SharedPreferences

                  // Get the user's document reference using their email
                  final snapshot = await firestore
                      .collection('Users')
                      .where('Email', isEqualTo: email)
                      .get();

                  // Update the password field in Firestore
                  if (snapshot.docs.isNotEmpty) {
                    final userDoc = snapshot.docs.first;
                    await userDoc.reference.update({'Password': newPassword});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password Updated Succesfully.')),
                    );
                    Navigator.pop(context); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error Updating Password.')),
                    );
                  }
                } catch (e) {
                  
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error Updating Password" $e')),
                    );
                  print('Error updating password: $e');
                }
              } else {
                // Show an error message or handle invalid passwords
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password is empty or incorrect.')),
                    );
              }
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

}

