import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import 'article.dart';

void pickAvatar(DataProvider dataProvider, Function onUploading,
    Function onUploaded) async {
  File file = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    onUploading();
    uploadAvatar(file, dataProvider, onUploaded);
  }
}

void uploadAvatar(File file, DataProvider dataProvider, Function onUploaded) {
  final StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child("avatar_${dataProvider.firebaseUserID}");
  final StorageUploadTask storageUploadTask = storageReference.putFile(file);

  storageUploadTask.onComplete.then((StorageTaskSnapshot s) async {
    final url = await s.ref.getDownloadURL();
    updateAvatarURL(url, dataProvider).whenComplete(onUploaded);
  });
}

Future<void> updateAvatarURL(String url, DataProvider dataProvider) async {
  final map = {"avatarURL": url};
  await dataProvider.userDataReference.updateData(map);
}

Future<void> setUsername(String value, BuildContext context) {
  return DataProvider.of(context).userDataReference.updateData({"name": value});
}

Future<void> createUser(String firebaseUserID, Map<String, dynamic> map) {
  return Firestore.instance.runTransaction((transaction) {
    transaction.set(
        Firestore.instance.collection("users").document(firebaseUserID), map);
  });
}

Future<void> updateShoppingList(ShoppingList shoppingList) {
  return Firestore.instance
      .collection("shoppingLists")
      .document(shoppingList.id)
      .updateData(shoppingList.toMap());
}

Future<void> updateArticle(Article article) {
  return Firestore.instance
      .collection("articles")
      .document(article.id)
      .updateData(article.toMap());
}

Future<void> deleteArticle(String articleID){
  return Firestore.instance
      .collection("articles")
      .document(articleID)
      .delete();
}

Future<void> deleteArticleCompletely(Article article, ShoppingList shoppingList) {
  shoppingList.articlesIDs.remove(article.id);
  updateShoppingList(shoppingList);
  return deleteArticle(article.id);
}

Future<void> addArticle(Article article, ShoppingList shoppingList) {
  return Firestore.instance
      .collection("articles")
      .add(article.toMap())
      .then((documentReference) {
    shoppingList.articlesIDs.add(documentReference.documentID);
    updateShoppingList(shoppingList);
  });
}

Future<void> deleteShoppingList(ShoppingList shoppingList){
  shoppingList.articlesIDs.forEach((articleID) => deleteArticle(articleID));
  return Firestore.instance.collection("shoppingLists").document(shoppingList.id).delete();
}


Future<void> createShoppingList(ShoppingList shoppingList){
  return Firestore.instance.collection("shoppingLists").add(shoppingList.toMap());
}