import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sharedshopping/core/user.dart';
import 'package:sharedshopping/pages/sign_in_page.dart';
import 'package:sharedshopping/widgets/raised_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/data_tool.dart' as dataTool;

const double avatarRadius = 80;

class ProfileSettings extends StatelessWidget {
  const ProfileSettings();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, user) {
            if (user.hasData && !user.hasError) {
              return _buildContent(user.data);
            } else {
              return Expanded(
                flex: 9,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  child: Text("SIGN OUT"),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => _buildSingOutDialog(context));
                  },
                ),
                MaterialButton(
                  child: Text("HELP"),
                  onPressed: () {},
                ),
                MaterialButton(
                  child: Text("ABOUT"),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSingOutDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Sign out"),
      content: Text("Sign out of your current profile"),
      actions: <Widget>[
        MaterialButton(
          child: Text("CANCEL"),
          onPressed: () => Navigator.pop(context),
        ),
        MaterialButton(
          child: Text("SIGN OUT"),
          onPressed: () {
            FirebaseAuth.instance.signOut().whenComplete(() {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInPage()));
            }).catchError((e) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Failed to sign out")));
            });
          },
        )
      ],
    );
  }

  Widget _buildContent(FirebaseUser firebaseUser) {
    return Column(
      children: <Widget>[
        SizedBox(height: 48.0),
        StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(firebaseUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              final user = User.fromMap(snapshot.data.data);
              return AvatarSettings(firebaseUser, user.avatarURL);
            } else {
              return AvatarPlaceholder("LOADING...");
            }
          },
        ),
        SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: UsernameSettings(firebaseUser.uid),
        ),
      ],
    );
  }
}

class AvatarSettings extends StatefulWidget {
  final FirebaseUser firebaseUser;
  final String avatarURL;

  const AvatarSettings(this.firebaseUser, this.avatarURL);

  @override
  _AvatarSettingsState createState() => _AvatarSettingsState();
}

class _AvatarSettingsState extends State<AvatarSettings> {
  AvatarSelectionState avatarSelectionState;

  @override
  void initState() {
    super.initState();
    avatarSelectionState = AvatarSelectionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildAvatar(),
        MaterialButton(
          child: Text(
            _getAvatarActionText(),
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () => _getAvatarAction(),
        )
      ],
    );
  }

  String _getAvatarActionText() =>
      avatarSelectionState == AvatarSelectionState.normal
          ? "CHANGE"
          : "UPLOADING...";

  void _getAvatarAction() {
    if (avatarSelectionState == AvatarSelectionState.normal) {
      dataTool.pickAvatar(widget.firebaseUser.uid, () {
        setState(() {
          avatarSelectionState = AvatarSelectionState.uploading;
        });
      }, () {
        setState(() {
          avatarSelectionState = AvatarSelectionState.normal;
        });
      });
    } else {
      return null;
    }
  }

  Widget _buildAvatar() {
    return Material(
      borderRadius: BorderRadius.circular(90),
      elevation: 10,
      child: CachedNetworkImage(
        imageUrl: widget.avatarURL ?? "",
        imageBuilder: (context, provider) => CircleAvatar(
              backgroundImage: provider,
              maxRadius: avatarRadius,
            ),
        placeholder: (context, string) => AvatarPlaceholder("LOADING..."),
        errorWidget: (context, string, a) => AvatarPlaceholder("NO AVATAR"),
      ),
    );
  }
}

enum AvatarSelectionState { normal, uploading }

class AvatarPlaceholder extends StatelessWidget {
  final String text;

  const AvatarPlaceholder(this.text);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(text),
      radius: avatarRadius,
    );
  }
}

class UsernameSettings extends StatefulWidget {
  final String firebaseUserID;

  UsernameSettings(this.firebaseUserID);

  @override
  _UsernameSettingsState createState() => _UsernameSettingsState();
}

class _UsernameSettingsState extends State<UsernameSettings> {

  String _username;
  DocumentReference userDocument;

  @override
  void initState() {
    super.initState();
    userDocument =
        Firestore.instance.collection("users").document(widget.firebaseUserID);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userDocument.snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          var user = User.fromMap(snapshot.data.data);
          _username = user.name;

          return RaisedTextField(
            hintText: "Username",
            text: _username,
            maxLength: 20,
            onChange: (value) => _username = value,
            suffix: InkWell(
              borderRadius: BorderRadius.circular(45),
              child: Text(
                "UPDATE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: _setUsername,
            ),
          );
        } else {
          return Text("LOADING...");
        }
      },
    );
  }

  void _setUsername() {
    dataTool.setUsername(_username, widget.firebaseUserID).whenComplete(() {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Updated username successfully")));
    }).catchError((e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update username")));
    });
  }
}
