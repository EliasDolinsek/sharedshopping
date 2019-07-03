class User {

  String name;
  String avatarURL;

  User({this.name, this.avatarURL});

  factory User.fromMap(Map<dynamic, dynamic> map){
    return User(name: map["name"] ?? "unknwon", avatarURL: map["avatarURL"] ?? "");
  }
}