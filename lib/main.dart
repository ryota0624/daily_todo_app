import 'dart:async';

import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:daily_todo_app/widget/component_container.dart' as C;
import 'package:daily_todo_app/widget/todo_create_form.dart';
import 'package:flutter/material.dart';
import 'adapter/todo_collection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> _todos = [];
  TodoCollection _todoCollection = c.resolve<TodoCollection>();
  Timer _timer;

  _MyHomePageState() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      var todos = await _todoCollection.getAll();
      print(todos);
      setState(() {
        _todos = todos;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TodoCreateForm(c.resolve<CreateTodoUseCase>()),
              TodoListWidget(todos: _todos),
            ],
          ),
        ));
  }
}

C.Container container() {
  return C.Container()
      .add(TimeGetter, TimeGetterDartCoreImpl())
      .add(TodoLabelsFactory, TodoLabelsFactoryImpl())
      .add(TodoCollection, TodoCollectionOnMap())
      .build<TodoFactory>((resolver) =>
          TodoFactory(resolver<TimeGetter>(), resolver<TodoLabelsFactory>()))
      .build<CreateTodoUseCase>((resolver) => CreateTodoUseCaseImpl(
          todoCollection: resolver<TodoCollection>(),
          todoFactory: resolver<TodoFactory>(),
    ));
}

var c = container();

class CreateTodoUseCaseImpl extends CreateTodoUseCase
    with NoneOutputPort<CreateTodoResult> {
  CreateTodoUseCaseImpl({
    @required TodoFactory todoFactory,
    @required TodoCollection todoCollection,
  }) : super(todoFactory, todoCollection);
}

class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;

  const TodoListWidget({Key key, this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: todos.map((todo) {
        // TODO for式的なのなかったっけ？
        return TodoItem(todo: todo);
      }).toList(),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;

  // TODO Keyとはなんぞや調べる
  const TodoItem({Key key, this.todo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  Text(todo.subject().toString());
  }
}