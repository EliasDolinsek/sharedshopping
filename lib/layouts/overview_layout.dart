import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import 'package:sharedshopping/layouts/user_list_layout.dart';
import 'package:sharedshopping/pages/shopping_list_page.dart';
import '../core/data_tool.dart' as dataTool;

class ShoppingListsOverview extends StatefulWidget {
  const ShoppingListsOverview();

  @override
  _ShoppingListsOverviewState createState() => _ShoppingListsOverviewState();
}

class _ShoppingListsOverviewState extends State<ShoppingListsOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: DataProvider.of(context).shoppingListsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildLoadingIndicator();
          } else {
            return _buildShoppingListsList(snapshot.data);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildShoppingListsList(QuerySnapshot snapshot) {
    EdgeInsets getPaddingForIndex(int index) {
      if (index == snapshot.documents.length - 1)
        return EdgeInsets.symmetric(horizontal: 8, vertical: 8);
      return EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0);
    }

    if (snapshot.documents.length == 0) {
      return Center(
        child: Text(
          "No shopping lists found",
          style: TextStyle(fontSize: 16, letterSpacing: 0.15),
        ),
      );
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          final document = snapshot.documents.elementAt(index);
          return Padding(
            padding: getPaddingForIndex(index),
            child: _buildShoppingListCard(
              ShoppingList.fromMap(document.data, document.documentID),
            ),
          );
        },
        itemCount: snapshot.documents.length,
      );
    }
  }

  Widget _buildShoppingListCard(ShoppingList shoppingList) {
    return InkWell(
      onTap: () => _showShoppingListPage(shoppingList.id, context),
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: null,
      label: FlatButton.icon(
        onPressed: () {
          final firebaseUserID = DataProvider.of(context).firebaseUserID;
          dataTool
              .createShoppingList(ShoppingList(
                  adminID: firebaseUserID,
                  userIDs: [firebaseUserID],
                  title: "New Shopping List"))
              .then((document) => _showShoppingListPage(document.documentID, context));
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          "CREATE",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

void _showShoppingListPage(String shoppingListID, BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ShoppingListPage(shoppingListID)));
}
