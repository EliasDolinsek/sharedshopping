class Article {
  
  String title;
  int quantity;
  double price;

  Article(
      {this.title, this.quantity, this.price});

  factory Article.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) return Article();

    return Article(
      title: map["title"] ?? "unknwon",
      quantity: map["quantity"] ?? 1,
      price: map["price"],
    );
  }
}
