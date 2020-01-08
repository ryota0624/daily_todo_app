import 'dart:async';

import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:daily_todo_app/widget/component_container.dart' as C;
import 'package:daily_todo_app/widget/todo_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      home: MyHomePage(title: 'Todo App'),
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
  Todos _todos = Todos.empty();
  TodoCollection _todoCollection = c.resolve<TodoCollection>();
  Timer _timer;

  void reloadTodos() async {
    var todos = await _todoCollection.getAll();
    setState(() {
      _todos = Todos(todos);
    });
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void onPressDone(Todo todo) {
    final collection = c.resolve<TodoCollection>();
    collection.store(todo.complete());
    reloadTodos();
  }

  void onPressCancel(Todo todo) {
    final collection = c.resolve<TodoCollection>();
    collection.store(todo.cancel());
    reloadTodos();
  }

  _MyHomePageState() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      reloadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: TodoListWidget(
                        todos: _todos,
                        onPressDone: onPressDone,
                        onPressCancel: onPressCancel),
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    child: TodoCreateForm(c.resolve<CreateTodoUseCase>()),
                    alignment: Alignment.bottomCenter,
                  ),
                ],
              )),
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
    with MixinEventPublisher, NoneOutputPort<CreateTodoResult> {
  CreateTodoUseCaseImpl({
    @required TodoFactory todoFactory,
    @required TodoCollection todoCollection,
  }) : super(todoFactory, todoCollection);

}

class TodoListWidget extends StatelessWidget {
  final Todos todos;

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  const TodoListWidget(
      {Key key,
      this.todos,
      this.onPressDone,
      this.onPressStart,
      this.onPressCancel,
      this.onPressReturnNotStartedYet})
      : super(key: key);

  Widget _listView(String label, List<Todo> todos) {
    if (todos.isEmpty) return Container();

    return Column(children: [
      Text(label),
      ListView(shrinkWrap: true, children: [
        for (var todo in todos)
          TodoListItem(
            todo: todo,
            key: ObjectKey(todo),
            onPressDone: onPressDone,
            onPressCancel: onPressCancel,
          ),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
//      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _listView("未完了", todos.selectNotFinished()),
        _listView("完了", todos.selectCompleted()),
        _listView("キャンセル済", todos.selectCanceled()),
      ],
    );
  }
}

typedef TodoApplyFunction = void Function(Todo todo);

class TodoListItem extends StatelessWidget {
  final Todo todo;

  const TodoListItem(
      {Key key,
      this.todo,
      this.onPressDone,
      this.onPressStart,
      this.onPressCancel,
      this.onPressReturnNotStartedYet})
      : super(key: key);

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  double get statusIconSize => 24.0;

  Widget get statusIcon {
    if (todo.isCompleted()) {
      return Icon(
        Icons.done,
        color: Colors.green,
        size: statusIconSize,
      );
    }

    if (todo.isCanceled()) {
      return Icon(
        Icons.cancel,
        color: Colors.red,
        size: statusIconSize,
      );
    }

    if (todo.isInProgress()) {
      return Icon(
        Icons.timer,
        color: Colors.green,
        size: statusIconSize,
      );
    }

    return GestureDetector(
        onTap: () => onPressDone(todo),
        child: Icon(
          Icons.done,
          color: Colors.grey,
          size: statusIconSize,
        ));
  }

  onSelectedStatusChangeChoice(StatusChangeChoice c) {
    switch (c) {
      case StatusChangeChoice.asCancel:
        onPressCancel(todo);
        break;
      case StatusChangeChoice.asNoStartedYet:
        onPressReturnNotStartedYet(todo);
        break;
      case StatusChangeChoice.asComplete:
        onPressDone(todo);
        break;
      case StatusChangeChoice.asInProgress:
        onPressStart(todo);
        break;
    }
  }

  Widget get statusChangeMenu {
    return PopupMenuButton(
      onSelected: onSelectedStatusChangeChoice,
      itemBuilder: (BuildContext context) {
        return StatusChangeChoice.values.map((StatusChangeChoice c) {
          return PopupMenuItem(
            child: Text(c.toString()),
            value: c,
          );
        }).toList();
      },
    );
  }

  // TODO LongTapでメニュー出現 -> Cancel, NotStartedYetからの即Completed を実行
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(child: statusIcon, padding: EdgeInsets.only(right: 10)),
      Text(todo.subject().toString()),
      Expanded(
          child: Container(
              child: statusChangeMenu, alignment: Alignment.centerRight))
    ]);
  }
}

enum StatusChangeChoice {
  asCancel,
  asNoStartedYet,
  asComplete,
  asInProgress,
}
