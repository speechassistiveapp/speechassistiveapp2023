import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_flutter_app/src/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../dashboard/drills/chatpage.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart';

class ListItem {
  final String name;
  final DateTime date;
  final bool status;

  ListItem({required this.name, required this.date, required this.status});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListItem> itemList = []; // List to store items
  TextEditingController _textEditingController = TextEditingController();
  final _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _showAddItemDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Practice Drill'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: 'Enter Title',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                final currentDate = DateTime.now();
                final formattedDate =
                    DateFormat('MM-dd-yyyy').format(currentDate);
                final itemName = _textEditingController.text;

                final prefs = await SharedPreferences.getInstance();
                final email = prefs.getString('email');

                final user = UserRepository.instance.getUserDetails(email!);

                try {
                  final existingItemList = await _fetchItemList();
                  existingItemList.add(ListItem(
                    name: itemName,
                    date: currentDate,
                    status: false, // Set the initial status as false
                  ));
                  await UserRepository.instance.saveItemList(
                      email, existingItemList);
                  setState(() {
                    itemList = existingItemList;
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text('Failed to save item. Please try again.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Color.fromARGB(255, 92, 192, 152)),
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 92, 192, 152),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 92, 192, 152),
        title: const Text('Practice Drills'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LineAwesomeIcons.angle_left, color: tWhiteColor,),
        ),
      ),
      drawer: drawer(),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: friendsBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Text(
                            'List of Drills',
                            style: h1().copyWith(
                              color: Color.fromARGB(255, 92, 192, 152),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<ListItem>>(
                            future: _fetchItemList(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final itemList = snapshot.data!;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: ListView.builder(
                                    itemCount: itemList.length,
                                    itemBuilder: (context, index) {
                                      final item = itemList[index];
                                      final formattedDate =
                                          DateFormat('MM-dd-yyyy')
                                              .format(item.date);

                                      if (item.status) {
                                        // If the status is true, return an empty container
                                        return Container();
                                      }
                                      
                                      return ListTile(
                                        title: Text(item.name),
                                        subtitle: Text(formattedDate),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            showDialog<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Confirmation'),
                                                  content: const Text('Are you sure you want to remove this drill?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: ButtonStyle(
                                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                      ),
                                                      child: const Text('CANCEL'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        _updateItemStatus(item, true);
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: ButtonStyle(
                                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                                      ),
                                                      child: const Text('REMOVE'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },

                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ChatPage(
                                                  index: itemList.indexOf(item),
                                                  id: item.name,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Failed to retrieve item list.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 16),
                child: FloatingActionButton(
                  onPressed: _showAddItemDialog,
                  backgroundColor: Color.fromARGB(255, 92, 192, 152),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ListItem>> _fetchItemList() async {
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
      final itemListData = snapshot.docs.first.data()['itemList'];
      if (itemListData == null) {
        return [];
      }
      final itemList = itemListData
          .map<ListItem>((itemData) => ListItem(
                name: itemData['name'],
                date: itemData['date'].toDate(),
                status: itemData['status'], // Retrieve the status from Firestore
              ))
          .toList();
      return itemList;
    } catch (e) {
      throw 'Failed to retrieve item list. Please try again.';
    }
  }



Future<void> _updateItemStatus(ListItem item, bool status) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final snapshot = await _db
        .collection('Users')
        .where('Email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      throw 'No user found with the provided email';
    }

    final userId = snapshot.docs.first.id;
    final itemListData = snapshot.docs.first.data()['itemList'];
    if (itemListData == null) {
      throw 'Item list is empty';
    }

    final updatedItemList = itemListData.map((itemData) {
      final String itemName = itemData['name'];
      final DateTime itemDate = itemData['date'].toDate();
      final bool itemStatus = itemData['status'];

      if (itemName == item.name &&
          itemDate == item.date &&
          itemStatus == item.status) {
        return {
          'name': itemName,
          'date': itemDate,
          'status': status, // Update the status of the specific item
        };
      }

      return itemData;
    }).toList();

    await _db.collection('Users').doc(userId).update({
      'itemList': updatedItemList,
    });

    setState(() {
      itemList = updatedItemList
          .where((itemData) => itemData['status'] == false) // Filter out items with status = true
          .map<ListItem>((itemData) => ListItem(
                name: itemData['name'],
                date: itemData['date'].toDate(),
                status: itemData['status'],
              ))
          .toList();
    });
  } catch (e, stackTrace) {
    
    print('Failed to update item status: $e');
    print('Stack trace: $stackTrace');
    /*showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update item status. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );*/
  }
}

static drawer() {
    return Drawer(
      backgroundColor: Colors.indigo.shade400,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
          child: Theme(
            data: ThemeData.dark(),
            child: Column(
              children: const [
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                  radius: 60,
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 10),
                Divider(
                  color: Colors.white,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static TextStyle h1() {
    return const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white);
  }

  static friendsBox() {
    return const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)));
  }

}