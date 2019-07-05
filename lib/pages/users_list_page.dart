import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import 'package:sharedshopping/core/user.dart';
import '../core/data_tool.dart' as dataTool;

class UsersListPage extends StatefulWidget {
  final String shoppingListID;

  const UsersListPage(this.shoppingListID);

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  ShoppingList _shoppingList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: _buildActions(),
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            _shoppingList =
                ShoppingList.fromMap(snapshot.data.data, widget.shoppingListID);
            return ListView.separated(
              itemCount: _shoppingList.userIDs.length,
              itemBuilder: (context, index) =>
                  _buildUserItem(_shoppingList.userIDs.elementAt(index)),
              separatorBuilder: (context, index) => Divider(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        stream: Firestore.instance
            .collection("shoppingLists")
            .document(widget.shoppingListID)
            .snapshots(),
      ),
    );
  }

  Widget _buildUserItem(String userID) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection("users").document(userID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          final user =
              User.fromMap(snapshot.data.data, snapshot.data.documentID);
          return ListTile(
            title: Text(
              user.name,
              style: TextStyle(
                  fontWeight: _isUserCurrentUser(user, context)
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
            leading: CachedNetworkImage(
              imageUrl: user.avatarURL,
              placeholder: (context, string) => CircleAvatar(
                    child: Text(user.name.substring(0, 1)),
                  ),
              imageBuilder: (context, image) => CircleAvatar(
                    backgroundImage: image,
                  ),
            ),
            subtitle: Text(user.email),
            trailing: _buildTailing(user),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildTailing(User user) {
    if (_isCurrentUserAdmin() && !_isUserCurrentUser(user, context)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_upward,
              color: Colors.black,
            ),
            onPressed: () => _showMakeAdminDialog(user),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.redAccent,
            ),
            onPressed: () => _showRemoveUserDialog(user),
          ),
        ],
      );
    } else {
      return Container(width: 0, height: 0);
    }
  }

  List<Widget> _buildActions() {
    return [
      MaterialButton(
        child: Text("ADD USER"),
        onPressed: () => _addUser(),
      )
    ];
  }

  void _showMakeAdminDialog(User user) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Change admin rights"),
            content: Text(
                "Do you really want to transfer your admin rights to ${user.name}?"),
            actions: <Widget>[
              MaterialButton(
                child: Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              MaterialButton(
                child: Text("TRANFER"),
                onPressed: () {
                  dataTool.transferAdminRightsToUser(user, _shoppingList);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _showRemoveUserDialog(User user) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Remove ${user.name}"),
            content: Text("Do you really want to remove this user?"),
            actions: <Widget>[
              MaterialButton(
                child: Text("CANCLE"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              MaterialButton(
                child: Text("REMOVE"),
                onPressed: () {
                  dataTool.removeUserFromShoppingList(_shoppingList, user);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  bool _isCurrentUserAdmin() =>
      DataProvider.of(context).firebaseUserID == _shoppingList.adminID;

  bool _isUserCurrentUser(User user, BuildContext context) =>
      DataProvider.of(context).firebaseUserID == user.id;

  void _addUser() {
    if (_isCurrentUserAdmin()) {
      showModalBottomSheet(context: context, builder: (context) => AddUser(_shoppingList));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Can't add user"),
            content: Text("Users can only be added by the admin"),
            actions: <Widget>[
              MaterialButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }
  }
}

class AddUser extends StatefulWidget {
  final ShoppingList shoppingList;

  const AddUser(this.shoppingList);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {

  String _email = "", _error = null;
  bool _errorActive = false;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Add user",
                  style: TextStyle(fontSize: 16, letterSpacing: 0.15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "E-Mail",
                    errorText: _errorActive ? "Couldn't add user" : null,
                  ),
                  onChanged: (value) {
                    _email = value;
                    setState(() => _errorActive = false);
                  },
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      onPressed: _addUser,
                      child: Text("ADD USER", style: TextStyle(color: Colors.white)),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  void _addUser() async {
    await dataTool
        .addUserToShoppingListByEmail(_email, widget.shoppingList)
        .catchError((e) {
      setState(() {
        _errorActive = true;
      });
    });

    if(!_errorActive){
      Navigator.pop(context);
    }
  }
}
