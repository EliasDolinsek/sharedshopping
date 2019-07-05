import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/data_tool.dart' as dataTool;

import '../main.dart';
import 'main_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final _firebaseAuth = FirebaseAuth.instance;

  bool signingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 84.0),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: <Widget>[
                  Text(
                    "SharedShopping",
                    style: TextStyle(fontSize: 48, letterSpacing: 0.25),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Share shopping lists, in real time!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: signingIn
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: OutlineButton(
                child: Text("SIGN IN WITH GOOGLE"),
                onPressed: () => _signInWithGoogle(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _signInWithGoogle() async {
    setState(() {
      signingIn = true;
    });

    final googleSignInAccount = await _googleSignIn.signIn();

    var avatarURL;
    var name;

    try {
      avatarURL = googleSignInAccount.photoUrl;
      name = googleSignInAccount.displayName;
    } on Exception {
      setState(() {
        signingIn = false;
      });

      return;
    }

    final googleSignInAuthentication = await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    await _firebaseAuth
        .signInWithCredential(credential)
        .then((FirebaseUser user) async {
      if (!await _hasUserData(user.uid)) {
        _setupAccount(avatarURL, name, user).whenComplete(_showMainPage);
      } else {
        _showMainPage();
      }
    }).catchError((e) {
      setState(() {
        signingIn = false;
      });
    });
  }

  Future<void> _setupAccount(
      String avatarULR, String name, FirebaseUser user) async {
    return dataTool
        .createUser(user.uid, {"avatarURL": avatarULR, "name": name});
  }

  Future<bool> _hasUserData(String firebaseUserID) async {
    Stream<DocumentSnapshot> stream = await Firestore.instance
        .collection("users")
        .document(firebaseUserID)
        .snapshots();
    return (await stream.first).exists;
  }

  void _showMainPage() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
  }
}
