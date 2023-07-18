import 'package:flutter/material.dart';
import 'package:login_flutter_app/src/constants/colors.dart';

class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDoList'),
      ),
      body: Center(
        child: Text(
          'Welcome to the ToDoList! \n\n Comming Soon!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
