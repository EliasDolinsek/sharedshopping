import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sharedshopping/core/article.dart';
import 'package:sharedshopping/core/shopping_list.dart';
import 'package:sharedshopping/pages/users_list_page.dart';
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
        actions: _buildActions(),
      ),
      body: ListView(
        children: <Widget>[
          _buildTitleSetting(),
          SizedBox(height: 16.0),
          ShoppingListArticlesList(_shoppingList),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: FlatButton.icon(
          onPressed: () => dataTool.addArticle(Article(), _shoppingList),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            "ADD ARTICLE",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
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
      IconButton(
        icon: Icon(Icons.person),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UsersListPage(_shoppingList.id)),),
      )
    ];
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: TextField(
        controller: _textEditingController,
        decoration:
            InputDecoration(border: OutlineInputBorder(), labelText: "Title"),
        onChanged: (value) {
          _updateTitle(value);
        },
      ),
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
    return Column(
      children: shoppingList.articlesIDs
          .map((articleID) => _buildArticleCard(articleID))
          .toList(),
    );
  }

  Widget _buildArticleCard(String articleID) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
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
              return _buildArticleCardContent(Article.fromMap(
                  snapshot.data.data, snapshot.data.documentID));
            } else if (!snapshot.hasError) {
              return _buildArticleError();
            } else {
              return _buildArticleLoading();
            }
          },
        ),
      ),
    );
  }

  Widget _buildArticleCardContent(Article article) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          _buildArticleTitleAndActions(article),
          _buildArticleNote(article),
        ],
      ),
    );
  }

  Widget _buildArticleError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          "COULD NOT LOAD ARTICLE",
        ),
      ),
    );
  }

  Widget _buildArticleLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildArticleTitleAndActions(Article article) {
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
