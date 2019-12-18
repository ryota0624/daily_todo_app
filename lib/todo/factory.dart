import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/todo/label.dart';

class TodoFactory {
  final TimeGetter _timeGetter;
  final TodoLabelsFactory<List<Label>> _labelsFactory;
  TodoFactory(this._timeGetter, this._labelsFactory);

  Todo create({
    Subject subject,
    Description description,
    List<Label> labels,
  })  {
    final id = ID.create();
    final status = NotStartedYet();
    final createdAt = _timeGetter.now();
    return Todo(id, _labelsFactory.create(labels), subject, description,
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
