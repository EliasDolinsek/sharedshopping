import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sharedshopping/core/user.dart';
import 'package:sharedshopping/widgets/raised_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

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
                  onPressed: () {},
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

  Widget _buildContent(FirebaseUser firebaseUser) {
    return Column(
      children: <Widget>[
        SizedBox(height: 48.0),
        StreamBuilder(
          stream: Firestore.instance.collection("users").document(firebaseUser.uid).snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasData && !snapshot.hasError){
              final user = User.fromMap(snapshot.data.data);
              return _buildProfilePicture(user.avatarURL);
            } else {
              return _buildAvatarLoadingPlaceholder();
            }
          },
        ),
        SizedBox(
          height: 48.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: UsernameSettings(firebaseUser.uid),
        ),
        SizedBox(height: 16.0),
        Text(
          firebaseUser.email ?? "unknwon email",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProfilePicture(String avatarURL) {
    return Material(
      borderRadius: BorderRadius.circular(90),
      elevation: 10,
      child: CachedNetworkImage(
        imageUrl:
            avatarURL,
        imageBuilder: (context, provider) => CircleAvatar(
          backgroundImage: provider,
          maxRadius: 80,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton.icon(
                onPressed: () {
                  ImagePicker.pickVideo(source: ImageSource.gallery);
                },
                icon: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                ),
                label: Text("CHANGE", style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ),
        placeholder: (context, string) => _buildAvatarLoadingPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarLoadingPlaceholder(){
    return Icon(Icons.person);
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
              onTap: () => _updateUsername(_username, userDocument),
            ),
          );
        } else {
          return Text("LOADING...");
        }
      },
    );
  }

  void _updateUsername(String value, DocumentReference userDocument) {
    userDocument.updateData({"name": value}).whenComplete(() {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Updated username successfully")));
    }).catchError((e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update username")));
    });
  }
}
