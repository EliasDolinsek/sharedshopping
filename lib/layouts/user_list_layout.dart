import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/core/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UsersList extends StatelessWidget {
  final List<String> userIDs;

  const UsersList({this.userIDs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children:
            userIDs.map((userID) => _buildUserAvatar(context, userID)).toList(),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, String userID) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection("users").document(userID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasError && snapshot.hasData){
          var user = User.fromMap(snapshot.data.data);

          return CachedNetworkImage(
              imageUrl: user.avatarURL,
              placeholder: (context, string) =>
                  _buildAvatarLoadingPlaceholder(user.name),
              imageBuilder: (context, imageProvider) =>
                  CircleAvatar(backgroundImage: imageProvider));
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildAvatarLoadingPlaceholder(String userName){
    return CircleAvatar(child: Text(userName.substring(0, 1)));
  }
}
