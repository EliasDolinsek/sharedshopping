import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/core/article.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import '../core/data_tool.dart' as dataTool;

class ShoppingListPage extends StatefulWidget {
  final String shoppingListID;

  const ShoppingListPage(this.shoppingListID);

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  ShoppingList _shoppingList;
  TextEditingController _textEditingController;
  String _title;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("shoppingLists")
          .document(widget.shoppingListID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.hasError) {
          _setup(snapshot.data.data);
          return _buildContent();
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

  Widget _buildContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_shoppingList.title, style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: <Widget>[
          _buildDoneIconButton(),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.redAccent,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => _buildDeleteShoppingListDialog());
            },
          ),
          IconButton(icon: Icon(Icons.person), onPressed: () {})
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildTitleSetting(),
            SizedBox(height: 16.0),
            ShoppingListArticlesList(_shoppingList),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteShoppingListDialog() {
    return AlertDialog(
      title: Text("Delete shopping list"),
      content: Text("Do you really want to delte this shopping list?"),
      actions: <Widget>[
        MaterialButton(
            child: Text("CANCLE"), onPressed: () => Navigator.pop(context)),
        MaterialButton(
          child: Text("DELETE"),
          onPressed: () {
            Navigator.pop(context);
            dataTool.deleteShoppingList(_shoppingList);
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  Widget _buildTitleSetting() {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
              icon: Icon(Icons.check), onPressed: () => _updateTitle(_title)),
          labelText: "Title"),
      onChanged: (value) {
        _title = value;
      },
    );
  }

  Widget _buildDoneIconButton() {
    return _shoppingList.done
        ? IconButton(
            icon: Icon(Icons.close, color: Colors.redAccent),
            onPressed: _changeDoneStatus,
          )
        : IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.green,
            ),
            onPressed: _changeDoneStatus,
          );
  }

  void _updateTitle(String title) {
    _shoppingList.title = title;
    dataTool.updateShoppingList(_shoppingList);
  }

  void _changeDoneStatus() {
    _shoppingList.done = !_shoppingList.done;
    dataTool.updateShoppingList(_shoppingList);
  }

  void _setup(Map shoppingListMap) {
    _shoppingList =
        ShoppingList.fromMap(shoppingListMap, widget.shoppingListID);
    _title = _shoppingList.title;

    _textEditingController.text = _title;
    _textEditingController.selection =
        TextSelection.collapsed(offset: _title.length);
  }
}

class ShoppingListArticlesList extends StatelessWidget {
  final ShoppingList shoppingList;

  const ShoppingListArticlesList(this.shoppingList);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: _buildWidgetForIndex(index),
          );
        },
        itemCount: shoppingList.articlesIDs.length + 1,
      ),
    );
  }
  
  Widget _buildWidgetForIndex(int index){
    if (index == shoppingList.articlesIDs.length) {
      return _buildAddArticleCard();
    } else {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: _buildArticle(shoppingList.articlesIDs.elementAt(index)),
      );
    }
  }
  
  Widget _buildAddArticleCard(){
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(15),
      child: FlatButton.icon(
        onPressed: () {
          dataTool.addArticle(Article(), shoppingList);
        },
        icon: Icon(Icons.add),
        label: Text("ADD ARTICLE"),
      ),
    );
  }

  Widget _buildArticle(String articleID) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(15),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("articles")
              .document(articleID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              final article =
                  Article.fromMap(snapshot.data.data, snapshot.data.documentID);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    _buildArticleTitleActionControls(article),
                    _buildArticleNote(article),
                  ],
                ),
              );
            } else if (!snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "COULD NOT LOAD ARTICLE",
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildArticleTitleActionControls(Article article) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.redAccent,
          ),
          onPressed: () {
            dataTool.deleteArticleCompletely(article, shoppingList);
          },
        ),
        Expanded(
          child: TextField(
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.15),
            controller: TextEditingController(text: article.title)
              ..selection =
                  TextSelection.collapsed(offset: article.title.length),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: "Title"),
            onChanged: (value) {
              article.title = value;
              dataTool.updateArticle(article);
            },
          ),
        ),
        Checkbox(
          value: article.done,
          onChanged: (value) {
            article.done = value;
            dataTool.updateArticle(article);
          },
        )
      ],
    );
  }

  Widget _buildArticleNote(Article article) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46.0),
      child: TextField(
          controller: TextEditingController(text: article.note)
            ..selection = TextSelection.collapsed(offset: article.note.length),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Note",
          ),
          onChanged: (value) {
            article.note = value;
            dataTool.updateArticle(article);
          }),
    );
  }
}
