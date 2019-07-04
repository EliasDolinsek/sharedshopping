class ShoppingList {

  List<String> articlesIDs, userIDs;
  String title, adminID, id;
  bool done;

  ShoppingList({this.articlesIDs = const [], this.title = "", this.userIDs = const [], this.done = false, this.adminID = "", this.id});

  factory ShoppingList.fromMap(Map<dynamic, dynamic> map, String id) {
    if (map == null) return ShoppingList();

    return ShoppingList(
      articlesIDs: List<String>.from(map["articles"]) ?? [],
      userIDs: List<String>.from(map["userIDs"]),
      title: map["title"] ?? "unknown",
      done: map["done"] ?? false,
      adminID: map["adminID"] ?? "unknown",
      id: id
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "articles":articlesIDs,
      "userIDs":userIDs,
      "title":title,
      "done":done,
      "adminID":adminID,
    };
  }
}
