import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: App(),
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _controler = TextEditingController();
  List _toDoList = [];

  Map<String, dynamic> _lastRemove = Map();
  int _lastRemovePos = 0;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDoList() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _controler.text;
      _controler.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);

      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas!"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(right: 15, left: 15),
                child: TextField(
                  controller: _controler,
                  decoration: InputDecoration(
                      labelText: "Nome da nova tarefa.",
                      labelStyle: TextStyle(color: Colors.blueGrey)),
                ),
              )),
              Padding(
                padding: EdgeInsets.only(right: 10, top: 10),
                child: RaisedButton(
                    color: Colors.blueGrey,
                    child: Icon(Icons.add, color: Colors.white),
                    onPressed: _addToDoList),
              )
            ],
          ),
          Expanded(
              child: ListView.builder(
                  padding: EdgeInsets.all(5),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem))
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (v) {
          setState(() {
            _toDoList[index]["ok"] = v;
          });
        },
      ),
      onDismissed: (direction) {
        _lastRemove = Map.from(_toDoList[index]);
        _lastRemovePos = index;
        _toDoList.removeAt(index);

        _saveData();

        final snack = SnackBar(
          content: Text("Tarefa ${_lastRemove["title"]} removida!"),
          action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovePos, _lastRemove);
                  _saveData();
                });
              }),
              duration: Duration(seconds: 5),
        );
        Scaffold.of(context).showSnackBar(snack);
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (er) {
      return "";
    }
  }
}
