class Article {
  
  String title, id, note;
  bool done;

  Article(
      {this.title = "", this.note = "", this.id, this.done = false});

  factory Article.fromMap(Map<dynamic, dynamic> map, String id) {
    if (map == null) return Article();

    return Article(
      title: map["title"] ?? "unknwon",
      note: map["note"] ?? "",
      done: map["done"] ?? false,
      id: id
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "title":title,
      "note":note,
      "done":done
    };
  }
}
