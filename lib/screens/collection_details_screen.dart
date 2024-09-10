import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/collection.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final Collection collection;

  CollectionDetailsScreen({required this.collection});

  @override
  _CollectionDetailsScreenState createState() => _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  StreamSubscription<ServiceNotificationEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = NotificationListenerService.notificationsStream.listen((event) {
      if (event.packageName == 'com.google.android.apps.nbu.paisa.user') {
        _processNotification(event.title ?? "");
      }
    });
  }

  void _processNotification(String title) {
    final nameParts = title.split(' paid');
    if (nameParts.length > 1) {
      final name = nameParts[0].trim();
      if (widget.collection.friendStatus.containsKey(name)) {
        Provider.of<AppState>(context, listen: false)
            .updateCollectionStatus(widget.collection, name, true);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final sortedFriends = widget.collection.friendStatus.keys.toList()..sort();
          return ListView(
            children: [
              ListTile(
                title: Text('Total Amount: ₹${widget.collection.amount}'),
                subtitle: Text('Paid: ${widget.collection.paidCount}/${widget.collection.totalCount}'),
              ),
              ...sortedFriends.map((friend) {
                final paid = widget.collection.friendStatus[friend] ?? false;
                return ListTile(
                  title: Text(friend),
                  trailing: Icon(
                    paid ? Icons.check_circle : Icons.circle_outlined,
                    color: paid ? Colors.green : Colors.grey,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}