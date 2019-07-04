import 'package:flutter/material.dart';
import 'package:sharedshopping/core/dataProvider.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import '../core/data_tool.dart' as dataTool;

class ShoppingListPage extends StatefulWidget {

  final ShoppingList shoppingList;

  const ShoppingListPage(this.shoppingList);

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        title: Text(widget.shoppingList.title, style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          IconButton(
            icon: widget.shoppingList.done ? Icon(Icons.close, color: Colors.red,) : Icon(Icons.done, color: Colors.green,),
            onPressed: (){
              dataTool.updateShoppingList(widget.shoppingList);
              setState(() {
                widget.shoppingList.done = !widget.shoppingList.done;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: (){},
          )
        ],
      ),
    );
  }
}
