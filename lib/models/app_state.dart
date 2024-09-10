import 'package:flutter/foundation.dart';
import 'collection.dart';
import 'friend.dart';

class AppState extends ChangeNotifier {
  List<Collection> collections = [];
  List<Friend> friends = [
    Friend(name: "Alice"),
    Friend(name: "Bob"),
    Friend(name: "Charlie"),
    // Add more friends here
  ];

  void addCollection(Collection collection) {
    collections.add(collection);
    notifyListeners();
  }

  void updateCollectionStatus(Collection collection, String friendName, bool paid) {
    final index = collections.indexOf(collection);
    if (index != -1) {
      collections[index].updateFriendStatus(friendName, paid);
      notifyListeners();
    }
  }

  void addFriend(String name) {
    friends.add(Friend(name: name));
    notifyListeners();
  }
}
