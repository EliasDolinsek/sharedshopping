class User {

  String name, email, avatarURL, id;

  User({this.name, this.avatarURL, this.email, this.id});

  factory User.fromMap(Map<dynamic, dynamic> map, String id){
    if(map == null) return User();
    return User(name: map["name"] ?? "unknwon", avatarURL: map["avatarURL"] ?? "", email: map["email"] ?? "unknown email", id: id ?? "");
  }
}