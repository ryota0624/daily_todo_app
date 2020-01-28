import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/todo/label.dart';
import 'package:meta/meta.dart';

class TodoFactory {
  TodoFactory(this._timeGetter, this._labelsFactory);

  final TimeGetter _timeGetter;
  final TodoLabelsFactory _labelsFactory;


  WithEvent<TodoCreated, Todo> create({
    @required ID<DailyTodoList> listID,
    @required Subject subject,
    @required List<Label> labels,
  }) {
    final id = ID<Todo>.create();
    final status = NotStarted();
    final createdAt = _timeGetter.now();
    final todo = Todo(
      id,
      listID,
      _labelsFactory.create(labels),
      subject,
      EmptyDescription(),
      status,
      createdAt,
    );

    return WithEvent(
        TodoCreated(
          todo.id(),
          todo.subject(),
        ),
        todo);
  }
}

// ignore: one_member_abstracts
abstract class TimeGetter {
  DateTime now();
}

class TimeGetterDartCoreImpl extends TimeGetter {
  @override
  DateTime now() => DateTime.now();
}

// ignore: one_member_abstracts
abstract class TodoLabelsFactory {
  TodoLabels create(Iterable<Label> l);
}

class TodoLabelsFactoryImpl extends TodoLabelsFactory {
  @override
  TodoLabels create(Iterable<Label> l) => TodoLabelsListImpl(l.toList());
}
