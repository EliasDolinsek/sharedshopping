import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SharedShopping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        final FirebaseUser user = snapshot.data;
        if (snapshot.hasData && !snapshot.hasError && user != null) {
          final firebaseUserID = user.uid;
          return DataProvider(
            child: MainPage(),
            shoppingListsQuery: Firestore.instance
                .collection("shoppingLists")
                .where("userIDs", arrayContains: firebaseUserID),
            userDataReference: Firestore.instance.collection("users").document(firebaseUserID),
            firebaseUserID: firebaseUserID,
          );
        } else if (user == null) {
          return SignInPage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

