import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/layouts/overview_layout.dart';
import 'package:sharedshopping/layouts/profile_settings_layout.dart';

import 'sign_in_page.dart';

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;
  static const List<Widget> _contents = [
    ShoppingListsOverview(),
    ProfileSettings(),
  ];

  @override
  void initState() {
    super.initState();
    _startSignInPageIfNotSignedIn();
  }

  void _startSignInPageIfNotSignedIn() async {
    if(await FirebaseAuth.instance.currentUser() == null){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SharedShopping",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: _contents.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("Shopping Lists"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profile"))
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
