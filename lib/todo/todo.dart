import 'dart:js_util';
import 'dart:math';

import 'package:daily_todo_app/todo/label.dart';

class ID<E> {
  final String _str;

  ID._(this._str);

  @override
  String toString() => _str;

  static ID<E> fromString<E>(String str) => ID._(str);

  static ID<E> create<E>() => fromString(Random(999).nextDouble().toString());
}

class Subject {}

class Description {}

class Todo {
  final ID<Todo> _id;
  final TodoLabels _labels;
  final Subject _subject;
  final Description _description;
  final Status _status;
  final DateTime _createdAt;

  Todo(this._id, this._labels, this._subject, this._description, this._status,
      this._createdAt);

  ID<Todo> id() => _id;

  TodoLabels labels() => _labels;

  Subject subject() => _subject;

  Description description() => _description;

  Status status() => _status;

  DateTime createdAt() => _createdAt;

  Todo _changeStatus(Status status) =>
      Todo(_id, _labels, _subject, _description, status, _createdAt);

  Todo complete() => _changeStatus(status().complete());

  Todo cancel() => _changeStatus(status().cancel());

  Todo changeSubject(Subject s) =>
      Todo(_id, _labels, s, _description, _status, _createdAt);

  Todo addDescription(Description d) =>
      Todo(_id, _labels, _subject, d, _status, _createdAt);

  Todo addLabel(Label l) =>
      Todo(_id, _labels.add(l), _subject, _description, _status, _createdAt);
}

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

abstract class TodoLabels {
  Iterable<Label> values();

  TodoLabels add(Label label);
}

class TodoLabelsListImpl extends TodoLabels {
  final List<Label> _list;

  TodoLabelsListImpl(this._list);

  @override
  TodoLabels add(Label label) {
    var copied = _list.toList();
    return TodoLabelsListImpl(copied);
  }

  @override
  Iterable<Label> values() => _list;
}

abstract class Status {
  Status start();
  Status complete();
  Status cancel();

  bool isCompleted();
  bool isCanceled();
  bool isFinished() {
    return this is Completed || this is Cancelled;
  }
}

class NotStartedYet extends Status {
  InProgress start() => InProgress(DateTime.now());

  cancel() => Cancelled(startedAt: DateTime.now(), cancelledAt: DateTime.now());

  Completed complete() =>
      Completed(startedAt: DateTime.now(), completedAt: DateTime.now());

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => false;
}

class InProgress extends Status {
  final DateTime startedAt;

  InProgress(this.startedAt);

  Completed complete() =>
      Completed(startedAt: startedAt, completedAt: DateTime.now());

  Cancelled cancel() =>
      Cancelled(startedAt: startedAt, cancelledAt: DateTime.now());

  Status start() => this;

  @override
  bool isCanceled() => false;
  @override
  bool isCompleted() => false;
}

class Completed extends Status {
  final DateTime startedAt;
  final DateTime completedAt;

  Completed({this.startedAt, this.completedAt});

  @override
  Status cancel() =>
      Cancelled(startedAt: startedAt, cancelledAt: DateTime.now());

  @override
  Status complete() => this;

  @override
  Status start() => this;

  @override
  bool isCanceled() => false;
  @override
  bool isCompleted() => true;
}

class Cancelled extends Status {
  final DateTime startedAt;
  final DateTime cancelledAt;

  Cancelled({this.startedAt, this.cancelledAt});

  @override
  Status cancel() => this;

  @override
  Status complete() =>
      Completed(startedAt: startedAt, completedAt: DateTime.now());

  @override
  Status start() => this;

  @override
  bool isCanceled() => true;

  @override
  bool isCompleted() => false;
}
