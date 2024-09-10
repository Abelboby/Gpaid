import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

void main() {
  runApp(const MyApp());
}

class Friend {
  final String name;
  bool hasPaid;

  Friend(this.name, {this.hasPaid = false});
}

class Collection {
  final String name;
  final double amount;
  List<Friend> friends;

  Collection({required this.name, required this.amount, required this.friends});
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  List<Collection> collections = [];
  Collection? selectedCollection;
  List<Friend> allFriends = [];
  bool isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    // Add some test data for friends
    allFriends = [
      Friend('Vinitha'),
      Friend('Anu'),
      Friend('Rahul'),
      Friend('Suresh'),
      Friend('John'),
      Friend('Maria'),
    ];
  }

  void startNewCollection(String name, double amount, List<Friend> selectedFriends) {
    setState(() {
      collections.add(Collection(name: name, amount: amount, friends: selectedFriends));
      selectedCollection = collections.last;
    });
    listenForNotifications(); // Start listening after creating the collection
  }

  void listenForNotifications() {
    _subscription = NotificationListenerService.notificationsStream.listen((event) {
      if (event.packageName == 'com.google.android.apps.nbu.paisa.user') {
        final title = event.title ?? "";
        // Extract name from notification title "Vinitha paid you ₹1.00"
        final name = title.split(' paid ')[0];

        if (selectedCollection != null) {
          for (var friend in selectedCollection!.friends) {
            if (friend.name == name) {
              setState(() {
                friend.hasPaid = true;
              });
              log("${friend.name} has paid.");
            }
          }
        }
      }
    });
  }

  Future<void> openCollectionDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    List<Friend> selectedFriends = [];

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by clicking outside the dialog
      builder: (BuildContext context) {
        bool selectAll = false;
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Collection Name',
                  ),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount to Collect',
                    
                  ),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text("Select All Friends"),
                  value: selectAll,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAll = value ?? false;
                      selectedFriends = selectAll ? List.from(allFriends) : [];
                    });
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: allFriends.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(allFriends[index].name),
                      value: selectedFriends.contains(allFriends[index]),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedFriends.add(allFriends[index]);
                          } else {
                            selectedFriends.remove(allFriends[index]);
                          }
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  startNewCollection(nameController.text, double.parse(amountController.text), selectedFriends);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildFriendTable(Collection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Collection: ${collection.name}, Amount: ₹${collection.amount}"),
        Text(
            "${collection.friends.where((f) => f.hasPaid).length} out of ${collection.friends.length} paid"),
        DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Paid')),
          ],
          rows: collection.friends
              .map((friend) => DataRow(cells: [
                    DataCell(Text(friend.name)),
                    DataCell(Text(friend.hasPaid ? "Paid" : "Not Paid")),
                  ]))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fund Collection Tracker'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                isSidebarOpen = !isSidebarOpen;
              });
            },
          ),
        ),
        body: Row(
          children: [
            if (isSidebarOpen)
              SizedBox(
                width: 200,
                child: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      const DrawerHeader(
                        child: Text('Collections'),
                      ),
                      for (var collection in collections)
                        ListTile(
                          title: Text(collection.name),
                          onTap: () {
                            setState(() {
                              selectedCollection = collection;
                              isSidebarOpen = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: selectedCollection == null
                    ? const Text('Select or create a collection')
                    : buildFriendTable(selectedCollection!),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openCollectionDialog(); // Open dialog to create a new collection
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
