import 'dart:async';

import 'package:daily_todo_app/adapter/daily_todo_list_collection.dart';
import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/service/navigation.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/change_todo_status.dart';
import 'package:daily_todo_app/usecase/create_todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:daily_todo_app/widget/component_container.dart' as component;
import 'package:daily_todo_app/widget/todo_create_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'adapter/todo_collection.dart';
import 'errors/enum_error.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      onGenerateRoute: onGenerateRoute([
//        RouteWidgetBuilder.route<TodoDetailRoute>(
//          TodoDetailPage.fromRoute,
//        ),
//        RouteWidgetBuilder.route<DailyTodoListRoute>(
//            DailyTodoListPage.fromRoute),
//      ]),
        onGenerateRoute: routeSetting((dynamic route) {
          route<TodoDetailRoute>(TodoDetailPage.fromRoute);
          route<DailyTodoListRoute>(DailyTodoListPage.fromRoute);
        }),
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ChangeNotifierProvider<DailyTodoListScreenModel>.value(
          value: DailyTodoListScreenModelFWidget(
            container().resolve<DailyTodoListCollection>(),
            container().resolve<TodoCollection>(),
          ),
          child: Consumer<DailyTodoListScreenModel>(
            builder: (ctx, model, _) =>
                DailyTodoListScreen(title: 'Todo App', model: model),
          ),
        ));
  }
}

abstract class DailyTodoListScreenModel
    with WithEventSubscriber, ChangeNotifier {
  DailyTodoListScreenModel(this.dailyTodoListCollection, this.todoCollection) {
    _subscribeID = eventSubscriber.subscribe((Event evt) {
      // TODO(ryota0624): eventの種類によって List or Todoのreloadを分ける
      reloadTodos();
    });
  }

  final TodoCollection todoCollection;
  final DailyTodoListCollection dailyTodoListCollection;

  // mutable
  SubscribeID _subscribeID;
  DailyTodoList _selected;
  ID<DailyTodoList> selectedListID;
  Todos _todos = Todos.empty();

  // getters
  Todos get todos => _todos;

  DailyTodoList get selectedList => _selected;

  Future<void> reloadTodos() async {
    final todos = await (_selected == null
        ? todoCollection.getAll()
        : todoCollection.getByListID(_selected.id));
    _todos = Todos(todos);
    notifyListeners();
  }

  Future<void> reloadDailyTodoList() async {
    if (_selected == null) {
      _selected = await dailyTodoListCollection.getByDate(Date.today());
    } else {
      _selected = await dailyTodoListCollection.get(_selected.id);
    }
    _todos = Todos.empty();
    notifyListeners();

    await reloadTodos();
  }

  @override
  void dispose() {
    eventSubscriber.remove(_subscribeID);
    super.dispose();
  }
}

class DailyTodoListScreenModelFWidget extends DailyTodoListScreenModel
    with MixinEventSubscriber {
  DailyTodoListScreenModelFWidget(
    DailyTodoListCollection dailyTodoListCollection,
    TodoCollection todoCollection,
  ) : super(dailyTodoListCollection, todoCollection);
}

class DailyTodoListScreen extends StatefulWidget {
  const DailyTodoListScreen({Key key, this.title, this.model})
      : super(key: key);
  final String title;
  final DailyTodoListScreenModel model;

  @override
  _DailyTodoListScreen createState() => _DailyTodoListScreen();
}

class _DailyTodoListScreen extends State<DailyTodoListScreen> {
//  final TodoCollection _todoCollection = c.resolve<TodoCollection>();
//  final DailyTodoListCollection _dailyTodoListCollection =
//      c.resolve<DailyTodoListCollection>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DailyTodoListWidgetContainer(
              list: widget.model.selectedList,
              todos: widget.model.todos,
            ),
          )),
    );
  }
}

// TODO(ryota0624): Container.of(ctx)から取れるようにしたい
component.Container container() {
  return component.Container()
      .add(TimeGetter, TimeGetterDartCoreImpl())
      .add(TodoLabelsFactory, TodoLabelsFactoryImpl())
      .add(TodoCollection, TodoCollectionOnMap())
      .add(DailyTodoListCollection, DailyTodoListCollectionOnMap())
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

component.Container c = container();

class DailyTodoListWidgetContainer extends StatelessWidget {
  const DailyTodoListWidgetContainer({
    Key key,
    @required this.list,
    @required this.todos,
  }) : super(key: key);

  final DailyTodoList list;
  final Todos todos;

  ChangeTodoStatusUseCase get changeTodoStatusUseCase =>
      c.resolve<ChangeTodoStatusUseCase>();

  void onPressDone(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.complete,
    ));
  }

  void onPressCancel(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.cancel,
    ));
  }

  void onPressStart(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.start,
    ));
  }

  void onPressReturnNotStartedYet(Todo todo) {
    changeTodoStatusUseCase.put(ChangeTodoStatusParam(
      todoID: todo.id(),
      status: ChangeTodoStatus.start,
    ));
  }

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
          child: ChangeNotifierProvider<TodoCreationModel>.value(
            value: TodoCreationModelFWidget(c.resolve<CreateTodoUseCase>()),
            child: TodoCreateForm(
              listID: list.id,
            ),
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
  const TodoListWidget({
    Key key,
    @required this.todos,
    @required this.onPressDone,
    @required this.onPressStart,
    @required this.onPressCancel,
    @required this.onPressReturnNotStartedYet,
  }) : super(key: key);

  final Todos todos;

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  Widget _listView(String label, List<Todo> todos) {
    if (todos.isEmpty) {
      return Container();
    }
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
        _listView('未完了', todos.selectNotFinished()),
        _listView('完了', todos.selectCompleted()),
        _listView('キャンセル済', todos.selectCanceled()),
      ],
    );
  }
}

typedef TodoApplyFunction = void Function(Todo todo);

class TodoListItem extends StatelessWidget {
  const TodoListItem(
      {Key key,
      @required this.todo,
      @required this.onPressDone,
      @required this.onPressStart,
      @required this.onPressCancel,
      @required this.onPressReturnNotStartedYet})
      : super(key: key);
  final Todo todo;

  final TodoApplyFunction onPressDone;

  final TodoApplyFunction onPressStart;

  final TodoApplyFunction onPressCancel;

  final TodoApplyFunction onPressReturnNotStartedYet;

  static const double statusIconSize = 24;

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

  void onSelectedStatusChangeChoice(StatusChangeChoice c) {
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
      Padding(child: statusIcon, padding: const EdgeInsets.only(right: 10)),
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
        return 'キャンセル';
      case StatusChangeChoice.asNoStartedYet:
        return '未着手';
      case StatusChangeChoice.asComplete:
        return '完了';
      case StatusChangeChoice.asInProgress:
        return '実施中';
      default:
        throw InvalidEnumArgumentException(this);
    }
  }
}

class TodoDetailPage extends StatelessWidget {
  const TodoDetailPage({Key key, this.todoID}) : super(key: key);

  // ignore: prefer_constructors_over_static_methods
  static TodoDetailPage fromRoute(TodoDetailRoute r) =>
      TodoDetailPage(todoID: r.todoID);
  final ID<Todo> todoID;

  @override
  Widget build(BuildContext context) {
    // TODO(ryota0624): implement build
    return null;
  }
}

class DailyTodoListPage extends StatelessWidget {
  const DailyTodoListPage({Key key, this.date}) : super(key: key);

  // ignore: prefer_constructors_over_static_methods
  static DailyTodoListPage fromRoute(DailyTodoListRoute r) => DailyTodoListPage(
        date: r.date,
      );
  final Date date;

  @override
  Widget build(BuildContext context) {
    // TODO(ryota0624): implement build
    return null; // DailyTodoListWidgetContainer(list: null, todos: null);
  }
}
