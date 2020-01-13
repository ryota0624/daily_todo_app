import 'dart:async';

import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/change_todo_status.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:daily_todo_app/widget/component_container.dart' as C;
import 'package:daily_todo_app/widget/todo_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'adapter/todo_collection.dart';
import 'errors/enum_error.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Todo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with MixinEventSubscriber {
  Todos _todos = Todos.empty();
  DailyTodoList _selected;
  ID<DailyTodoList> selectedListID;
  TodoCollection _todoCollection = c.resolve<TodoCollection>();
  DailyTodoListCollection _dailyTodoListCollection = c.resolve<DailyTodoListCollection>();


  void reloadTodos() async {
    var todos = await _todoCollection.getByListID(_selected.id);
    setState(() {
      _todos = Todos(todos);
    });
  }

  void reloadDailyTodoList() async {

    if (_selected == null) {
      _selected = await _dailyTodoListCollection.getByDate(Date.today());
    } else {
      _selected = await _dailyTodoListCollection.get(_selected.id);
    }

    reloadTodos();
  }

  void dispose() {
    eventSubscriber.remove(subscribeID);
    super.dispose();
  }

  SubscribeID subscribeID;

  _MyHomePageState() {
    // containerから取りたい
    subscribeID = eventSubscriber.subscribe((evt) {
      // TODO eventの種類によって List or Todoのreloadを分ける
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
            child: DailyTodoListPage(
              list: null,
              todos: _todos,
            ),
          )),
    );
  }
}

// TODO Container.of(ctx)から取れるようにしたい
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
          ))
      .build<ChangeTodoStatusUseCase>((resolver) => ChangeTodoStatusUseCaseImpl(
            todoCollection: resolver<TodoCollection>(),
            timeGetter: resolver<TimeGetter>(),
          ));
}

var c = container();

class DailyTodoListPage extends StatelessWidget {
  final DailyTodoList list;
  final Todos todos;

  ChangeTodoStatusUseCase get changeTodoStatusUseCase =>
      c.resolve<ChangeTodoStatusUseCase>();

  void onPressDone(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.Complete,
    ));
  }

  void onPressCancel(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.Cancel,
    ));
  }

  void onPressStart(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.Start,
    ));
  }

  void onPressReturnNotStartedYet(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.Start,
    ));
  }

  const DailyTodoListPage({
    Key key,
    @required this.list,
    @required this.todos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: TodoListWidget(
            todos: todos,
            onPressDone: onPressDone,
            onPressCancel: onPressCancel,
            onPressStart: onPressStart,
            onPressReturnNotStartedYet: onPressReturnNotStartedYet,
          ),
          alignment: Alignment.topCenter,
        ),
        Container(
          child: TodoCreateForm(
            listID: null,
            inputPort: c.resolve<CreateTodoUseCase>(),
          ),
          alignment: Alignment.bottomCenter,
        ),
      ],
    );
  }
}

class CreateTodoUseCaseImpl extends CreateTodoUseCase
    with MixinEventPublisher, NoneOutputPort<CreateTodoResult> {
  CreateTodoUseCaseImpl({
    @required TodoFactory todoFactory,
    @required TodoCollection todoCollection,
  }) : super(todoFactory, todoCollection);
}

class ChangeTodoStatusUseCaseImpl extends ChangeTodoStatusUseCase
    with MixinEventPublisher, NoneOutputPort<ChangeTodoStatusResult> {
  ChangeTodoStatusUseCaseImpl({
    @required TodoCollection todoCollection,
    @required TimeGetter timeGetter,
  }) : super(todoCollection, timeGetter);
}

class TodoCompleted extends UiEvent {}

class TodoCanceled extends UiEvent {}

class TodoReturnNotStartedYet extends UiEvent {}

class TodoListWidget extends StatelessWidget {
  final Todos todos;

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  const TodoListWidget({
    Key key,
    @required this.todos,
    @required this.onPressDone,
    @required this.onPressStart,
    @required this.onPressCancel,
    @required this.onPressReturnNotStartedYet,
  }) : super(key: key);

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
            onPressReturnNotStartedYet: onPressReturnNotStartedYet,
            onPressStart: onPressStart,
          ),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
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
      @required this.todo,
      @required this.onPressDone,
      @required this.onPressStart,
      @required this.onPressCancel,
      @required this.onPressReturnNotStartedYet})
      : super(key: key);

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  static const double statusIconSize = 24.0;

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
            child: Text(c.asString()),
            value: c,
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(child: statusIcon, padding: EdgeInsets.only(right: 10)),
      Text(todo.subject().toString()),
      Expanded(
          child: Container(
        child: statusChangeMenu,
        alignment: Alignment.centerRight,
      ))
    ]);
  }
}

enum StatusChangeChoice {
  asCancel,
  asNoStartedYet,
  asComplete,
  asInProgress,
}

extension on StatusChangeChoice {
  String asString() {
    switch (this) {
      case StatusChangeChoice.asCancel:
        return "キャンセル";
      case StatusChangeChoice.asNoStartedYet:
        return "未着手";
      case StatusChangeChoice.asComplete:
        return "完了";
      case StatusChangeChoice.asInProgress:
        return "実施中";
      default:
        throw InvalidEnumArgumentException(this);
    }
  }
}
