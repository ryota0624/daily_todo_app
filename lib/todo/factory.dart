import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/todo/label.dart';
import 'package:meta/meta.dart';

class TodoFactory {
  final TimeGetter _timeGetter;
  final TodoLabelsFactory<List<Label>> _labelsFactory;

  TodoFactory(this._timeGetter, this._labelsFactory);

  WithEvent<TodoCreated, Todo> create({
    @required ID<DailyTodoList> listID,
    @required Subject subject,
    @required List<Label> labels,
  }) {
    final id = ID.create<Todo>();
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

abstract class TimeGetter {
  DateTime now();
}

class TimeGetterDartCoreImpl extends TimeGetter {
  @override
  DateTime now() => DateTime.now();
}

abstract class TodoLabelsFactory<L extends Iterable> {
  TodoLabels create(L l);
}

class TodoLabelsFactoryImpl extends TodoLabelsFactory<List<Label>> {
  @override
  TodoLabels create(List<Label> l) => TodoLabelsListImpl(l.toList());
}
