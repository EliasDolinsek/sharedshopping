import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void pickAvatar(String firebaseUserID, Function onUploading, Function onUploaded) async {
  File file = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    onUploading();
    uploadAvatar(file, firebaseUserID, onUploaded);
  }
}

void uploadAvatar(File file, String firebaseUserID, Function onUploaded) {
  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("avatar_$firebaseUserID}");
  final StorageUploadTask storageUploadTask = storageReference.putFile(file);

  storageUploadTask.onComplete.then((StorageTaskSnapshot s) async {
    final url = await s.ref.getDownloadURL();
    updateAvatarURL(url, firebaseUserID).whenComplete(onUploaded);
  });
}

Future<void> updateAvatarURL(
    String url, String firebaseUserID) async {

  final userDocument = Firestore.instance
      .collection("users")
      .document(firebaseUserID);

  final map = {"avatarURL": url};
  await userDocument.updateData(map);
}

Future<void> setUsername(String value, String firebaseUserID) {
  return Firestore.instance.collection("users").document(firebaseUserID).updateData({"name": value});
}

Future<void> createUser(String firebaseUserID, Map<String, dynamic> map) {
  Firestore.instance.runTransaction((transaction){
    return transaction.set(Firestore.instance.collection("users").document(firebaseUserID), map);
  });
}