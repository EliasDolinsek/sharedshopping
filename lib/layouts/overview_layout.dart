import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import 'package:sharedshopping/layouts/user_list_layout.dart';
import 'package:sharedshopping/pages/shopping_list_page.dart';
import 'package:sharedshopping/widgets/raised_textfield.dart';
import '../core/data_tool.dart' as dataTool;

class ShoppingListsOverview extends StatefulWidget {
  const ShoppingListsOverview();

  @override
  _ShoppingListsOverviewState createState() => _ShoppingListsOverviewState();
}

class _ShoppingListsOverviewState extends State<ShoppingListsOverview> {

  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            RaisedTextField(
              onChange: (value) => setState(() => _search = value),
              hintText: "Search",
            ),
            SizedBox(
              height: 16.0,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: DataProvider.of(context).shoppingListsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildLoadingIndicator();
                } else {
                  return _buildShoppingListsList(snapshot.data);
                }
              },
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: FlatButton.icon(
          onPressed: () {
            final firebaseUserID = DataProvider.of(context).firebaseUserID;
            dataTool.createShoppingList(
                ShoppingList(adminID: firebaseUserID, userIDs: [firebaseUserID], title: "New Shopping List"));
          },
          icon: Icon(Icons.add),
          label: Text("CREATE"),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildShoppingListsList(QuerySnapshot snapshot) {
    if (snapshot.documents.length == 0) {
      return Expanded(
        child: Center(
          child: Text(
            "No shopping lists found",
            style: TextStyle(fontSize: 16, letterSpacing: 0.15),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: snapshot.documents.length,
          itemBuilder: (context, index){
            final document = snapshot.documents.elementAt(index);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: _buildShoppingListCard(
                  ShoppingList.fromMap(document.data, document.documentID)),
            );
          },
          separatorBuilder: (context, index) => SizedBox(
            height: 8.0,
          ),
        ),
      );
    }
  }

  Widget _buildShoppingListCard(ShoppingList shoppingList) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShoppingListPage(shoppingList.id)));
      },
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  shoppingList.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 34,
                      letterSpacing: 0.25,
                      color: shoppingList.done ? Colors.grey : Colors.black),
                ),
              ),
              Row(
                children: <Widget>[
                  Chip(
                    backgroundColor: Colors.black,
                    label: Text(
                      "${shoppingList.articlesIDs.length} ARTICLES",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Chip(
                    backgroundColor:
                        shoppingList.done ? Colors.green : Colors.redAccent,
                    label: Text(
                      shoppingList.done ? "DONE" : "NOT DONE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  _buildAdminChip(shoppingList)
                ],
              ),
              UsersList(
                userIDs: shoppingList.userIDs,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminChip(ShoppingList shoppingList) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            !snapshot.hasError &&
            shoppingList.adminID == snapshot.data.uid) {
          return Chip(
            backgroundColor: Theme.of(context).primaryColor,
            label: Text(
              "ADMIN",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
