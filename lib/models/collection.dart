class Collection {
  String name;
  double amount;
  Map<String, bool> friendStatus;

  Collection({required this.name, required this.amount, required List<String> friends})
      : friendStatus = Map.fromIterable(friends, key: (f) => f, value: (_) => false);

  void updateFriendStatus(String friendName, bool paid) {
    friendStatus[friendName] = paid;
  }

  int get paidCount => friendStatus.values.where((paid) => paid).length;
  int get totalCount => friendStatus.length;
}
