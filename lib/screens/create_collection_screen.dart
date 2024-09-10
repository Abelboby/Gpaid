import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/collection.dart';

class CreateCollectionScreen extends StatefulWidget {
  @override
  _CreateCollectionScreenState createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _amount = 0;
  List<String> _selectedFriends = [];
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Collection')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Collection Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Amount to Collect'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),
            SizedBox(height: 20),
            Text('Select Friends:', style: Theme.of(context).textTheme.titleMedium),
            CheckboxListTile(
              title: Text('Select All'),
              value: _selectAll,
              onChanged: (bool? value) {
                setState(() {
                  _selectAll = value!;
                  if (_selectAll) {
                    _selectedFriends = appState.friends.map((f) => f.name).toList();
                  } else {
                    _selectedFriends.clear();
                  }
                });
              },
            ),
            ...appState.friends.map((friend) {
              return CheckboxListTile(
                title: Text(friend.name),
                value: _selectedFriends.contains(friend.name),
                onChanged: (bool? value) {
                  setState(() {
                    if (value!) {
                      _selectedFriends.add(friend.name);
                    } else {
                      _selectedFriends.remove(friend.name);
                    }
                    _selectAll = _selectedFriends.length == appState.friends.length;
                  });
                },
              );
            }).toList(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newCollection = Collection(
                    name: _name,
                    amount: _amount,
                    friends: _selectedFriends,
                  );
                  appState.addCollection(newCollection);
                  Navigator.pop(context);
                }
              },
              child: Text('Create Collection'),
            ),
          ],
        ),
      ),
    );
  }
}