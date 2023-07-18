import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:login_flutter_app/src/features/authentication/models/user_model.dart';
import '../../features/core/screens/dashboard/drills/homepage.dart';
import '../authentication_repository/exceptions/t_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Store user data
  Future<void> createUser(UserModel user, ChildUser childUser) async {
  try {
    final userData = user.toJson();
    userData['childUser'] = jsonEncode(childUser.toJson()); // Convert the nested map to a JSON string
    
    await recordExist(user.email)
        ? throw "Record Already Exists"
        : await _db.collection("Users").add(userData);
  } on FirebaseAuthException catch (e) {
    final result = TExceptions.fromCode(e.code);
    print('FirebaseAuthException: ${result.message}'); 
    throw result.message;
  } on FirebaseException catch (e) {
    print('FirebaseException: ${e.message.toString()}');
    throw e.message.toString();
  } catch (e) {
    final errorMessage = e.toString().isEmpty ? 'Something went wrong. Please Try Again' : e.toString();
    print('Error: $errorMessage'); // Debug print for other exceptions
    throw errorMessage;
  }
}



/// Fetch User Specific details
  /// Fetch User Specific details
Future<UserModel> getUserDetails(String eemail) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    print('PREF EMAIL: $email');
    final snapshot = await _db.collection("Users").where("Email", isEqualTo: email).get();
    if (snapshot.docs.isEmpty) throw 'No such user found';
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    
    print('User Data: ${userData.toString()}'); // Debug print of userData
      prefs.setString('email', userData.email); // Save the email to preferences
      prefs.setString('pName', userData.fullName); // Save the email to preferences
      prefs.setString('pGender', userData.gender); // Save the email to preferences
      prefs.setString('pAvatar', userData.avatar); // Save the email to preferences

      final childInfo = userData.childInfo ?? '';
      final childInfoMap = jsonDecode(childInfo) as Map<String, dynamic>;

      final fullName = childInfoMap['FullName'];
      final gender = childInfoMap['Gender'];
      final avatar = childInfoMap['Avatar'];
      prefs.setString('cName', fullName); // Save the email to preferences
      prefs.setString('cGender', gender); // Save the email to preferences
      prefs.setString('cAvatar', avatar); // Save the email to preferences
    
    return userData;
  } on FirebaseAuthException catch (e) {
    final result = TExceptions.fromCode(e.code);
    throw result.message;
  } on FirebaseException catch (e) {
    throw e.message.toString();
  } catch (e) {
    throw e.toString().isEmpty ? 'Something went wrong. Please Try Again' : e.toString();
  }
}

Future<void> saveItemList(String email, List<ListItem> itemList) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final snapshot = await _db
        .collection('Users')
        .where("Email", isEqualTo: email)
        .get();
    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final existingItemListData =
        snapshot.docs.first.data()['itemList'] as List<dynamic>?;

    final existingItemList = existingItemListData != null
        ? existingItemListData
            .map<ListItem>((itemData) => ListItem(
                  name: itemData['name'],
                  date: itemData['date'].toDate(),
                  status: itemData['status'],
                ))
            .toList()
        : [];

    // Filter out existing items from the new item list
    final filteredItemList = itemList
        .where((item) => !existingItemList.any(
              (existingItem) =>
                  existingItem.name == item.name &&
                  existingItem.date == item.date &&
                  existingItem.status == item.status,
            ))
        .toList();

    final List<Map<String, dynamic>> newItemListData = filteredItemList
        .map((item) => {
              'name': item.name,
              'date': Timestamp.fromDate(item.date),
              'status': item.status,
              'isLocked': [false, true, true, true], // Add the _isLocked array
            })
        .toList();

    final updatedItemListData = [...?existingItemListData, ...newItemListData];

    final userId = snapshot.docs.first.id;
    await _db.collection('Users').doc(userId).update({
      'itemList': updatedItemListData,
    });
  } catch (e) {
    throw 'Failed to save item list. Please try again.';
  }
}






  /// Fetch All Users
  Future<List<UserModel>> allUsers() async {
    try {
      final snapshot = await _db.collection("Users").get();
      final users = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
      return users;
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  /// Update User details
  Future<void> updateUserRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).update(user.toJson());
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  /// Delete User Data
  Future<void> deleteUser(String id) async {
    try {
      await _db.collection("Users").doc(id).delete();
    } on FirebaseAuthException catch (e) {
      final result = TExceptions.fromCode(e.code);
      throw result.message;
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (_) {
      throw 'Something went wrong. Please Try Again';
    }
  }

  /// Check if user exists with email or phoneNo
  Future<bool> recordExist(String email) async {
    try {
      final snapshot = await _db.collection("Users").where("Email", isEqualTo: email).get();
      return snapshot.docs.isEmpty ? false : true;
    } catch (e) {
      throw "Error fetching record.";
    }
  }
}
