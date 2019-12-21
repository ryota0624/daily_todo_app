import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/todo/label.dart';
import 'package:meta/meta.dart';

class TodoFactory {
  final TimeGetter _timeGetter;
  final TodoLabelsFactory<List<Label>> _labelsFactory;

  TodoFactory(this._timeGetter, this._labelsFactory);

  Todo create({
    @required Subject subject,
    @required List<Label> labels,
  }) {
    final id = ID.create<Todo>();
    final status = NotStarted();
    final createdAt = _timeGetter.now();
    return Todo(id, _labelsFactory.create(labels), subject, EmptyDescription(),
        status, createdAt);
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
