class ShoppingList {

  List<String> articlesIDs, userIDs;
  String title, adminID;
  bool done;

  ShoppingList({this.articlesIDs, this.title, this.userIDs, this.done, this.adminID});

  factory ShoppingList.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return ShoppingList();

    return ShoppingList(
      articlesIDs: List<String>.from(map["articles"]) ?? [],
      userIDs: List<String>.from(map["userIDs"]),
      title: map["title"] ?? "unknown",
      done: map["done"] ?? false,
      adminID: map["adminID"] ?? "unknown"
    );
  }
}
