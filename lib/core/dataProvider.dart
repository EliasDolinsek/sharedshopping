import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataProvider extends InheritedWidget {

  final DocumentReference userDataReference;
  final Query shoppingListsQuery;

  final String firebaseUserID;

  const DataProvider({@required Widget child, @required this.userDataReference, @required this.shoppingListsQuery, @required this.firebaseUserID}) : super(child: child);

  static DataProvider of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(DataProvider);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  get userDataStream => userDataReference.snapshots();
  get shoppingListsStream => shoppingListsQuery.snapshots();
}
