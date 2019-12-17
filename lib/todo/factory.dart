import 'package:daily_todo_app/todo/todo.dart';
import 'package:daily_todo_app/todo/label.dart';

class TodoBuilder {
  final TimeGetter _timeGetter;
  final TodoLabelsFactory<List<Label>> _labelsFactory;

  Subject _subject;
  Description _description;
  List<Label> _labels;

  TodoBuilder(this._timeGetter, this._labelsFactory);

  TodoBuilder labels(List<Label> list) {
    _labels = list;
    return this;
  }

  TodoBuilder subject(Subject sub) {
    _subject = sub;
    return this;
  }

  TodoBuilder description(Description des) {
    _description = des;
    return this;
  }

  Todo build() {
    final id = ID.create();
    final status = NotStartedYet();
    final createdAt = _timeGetter.now();
    return Todo(id, _labelsFactory.create(_labels), _subject, _description,
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
