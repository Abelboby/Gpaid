// Update the screens/home_screen.dart file:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'create_collection_screen.dart';
import 'collection_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Collector'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Collections', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return Column(
                  children: appState.collections.map((collection) {
                    return ListTile(
                      title: Text(collection.name),
                      subtitle: Text('${collection.paidCount}/${collection.totalCount} paid'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionDetailsScreen(collection: collection),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Notification Collector',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Create your first collection to get started!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateCollectionScreen()),
                      );
                    },
                    child: Text('Create Collection'),
                  ),
                ],
              ),
            );
          } else {
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'Your Collections',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                ...appState.collections.map((collection) {
                  return Card(
                    child: ListTile(
                      title: Text(collection.name),
                      subtitle: Text('Amount: ₹${collection.amount}'),
                      trailing: Text(
                        '${collection.paidCount}/${collection.totalCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: collection.paidCount == collection.totalCount ? Colors.green : Colors.orange,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionDetailsScreen(collection: collection),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateCollectionScreen()),
                    );
                  },
                  child: Text('Create New Collection'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ... (rest of the code remains the same)