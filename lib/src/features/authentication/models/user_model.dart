import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNo;
  final String gender;
  final String password;
  final String avatar;
  final String? childInfo; // Add the childUser property

  /// Constructor
  const UserModel(
      {this.id, required this.email, required this.password, required this.fullName, required this.phoneNo, required this.gender,
    required this.avatar,this.childInfo,});

  set childUser(ChildUser childUser) {}

  /// convert model to Json structure so that you can it to store data in Firesbase
  toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Phone": phoneNo,
      "Password": password,
      "Gender": gender,
      "Avatar": avatar +'.png',
      "childUser": childInfo, 
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      email: data["Email"],
      password: data["Password"],
      fullName: data["FullName"],
      phoneNo: data["Phone"],
      gender: data["Gender"],
      avatar: data["Avatar"],
      childInfo: data["childUser"], 
    );
  }
}


class ChildUser {
  final String fullName;
  final String gender;
  final String avatar;

  ChildUser({
    required this.fullName,
    required this.gender,
    required this.avatar,
  });

  toJson() {
    return {
      "FullName": fullName,
      "Gender": gender,
      "Avatar": avatar + '.png',
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory ChildUser.fromJson(Map<String, dynamic> json) {
    return ChildUser(
      fullName: json['FullName'],
      gender: json['Gender'],
      avatar: json['Avatar'],
    );
  }
}
