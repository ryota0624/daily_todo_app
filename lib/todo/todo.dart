import 'dart:math';

import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/todo/label.dart';

class ID<E> {
  final String _str;

  ID._(this._str);

  @override
  String toString() => _str;

  static ID<E> fromString<E>(String str) => ID._(str);

  static ID<E> create<E>() => fromString(Random(999).nextDouble().toString());
}

class Subject {
  final String _text;

  Subject(this._text);

  @override
  String toString() => _text;
}

abstract class Description {
  bool isEmpty();
}

class TextDescription extends Description {
  final String _text;

  TextDescription(this._text);

  @override
  bool isEmpty() => _text.isEmpty;
}

class EmptyDescription extends Description {
  bool isEmpty() => true;
}

class Todos {
  final List<Todo> _values;

  Todos(this._values);

  Todos put(Todo t) => Todos([..._values.where((t2) => t2.id() != t.id()), t]);

  static Todos empty() => Todos([]);

  List<Todo> selectCompleted() =>
      _values.where((todo) => todo.isCompleted()).toList();

  List<Todo> selectCanceled() =>
      _values.where((todo) => todo.isCanceled()).toList();

  List<Todo> selectNotFinished() =>
      _values.where((todo) => !todo.isFinished()).toList();

  bool isAllFinished() {
    return selectNotFinished().length == 0 && selectCompleted().length > 1;
  }
}

class Todo {
  final ID<Todo> _id;
  final ID<DailyTodoList> _listID;
  final TodoLabels _labels;
  final Subject _subject;
  final Description _description;
  final Status _status;
  final DateTime _createdAt;

  Todo(this._id, this._listID, this._labels, this._subject, this._description,
      this._status, this._createdAt);

  ID<Todo> id() => _id;

  ID<DailyTodoList> listID() => _listID;

  TodoLabels labels() => _labels;

  Subject subject() => _subject;

  Description description() => _description;

  Status status() => _status;

  DateTime createdAt() => _createdAt;

  bool isFinished() => status().isFinished();

  bool isCompleted() => status().isCompleted();

  bool isCanceled() => status().isCanceled();

  bool isInProgress() => status().isInProgress();

  bool hasLabel(Label label) => labels().contains(label);

  WithEvent<TodoStatusChanged, Todo> _changeStatus(Status status) {
    final todo =
        Todo(_id, _listID, _labels, _subject, _description, status, _createdAt);
    return WithEvent(TodoStatusChanged(todo.id(), todo.status()), todo);
  }

  WithEvent<TodoStatusChanged, Todo> complete(DateTime completedAt) =>
      _changeStatus(status().complete(completedAt));

  WithEvent<TodoStatusChanged, Todo> cancel(DateTime canceledAt) =>
      _changeStatus(status().cancel(canceledAt));

  WithEvent<TodoStatusChanged, Todo> start(DateTime startedAt) =>
      _changeStatus(status().start(startedAt));

  WithEvent<TodoStatusChanged, Todo> asNotStartedYet() =>
      _changeStatus(status().asNotStartedYet());

  Todo changeSubject(Subject s) =>
      Todo(_id, _listID, _labels, s, _description, _status, _createdAt);

  Todo changeDescription(Description d) =>
      Todo(_id, _listID, _labels, _subject, d, _status, _createdAt);

  Todo addLabel(Label l) => Todo(_id, _listID, _labels.add(l), _subject,
      _description, _status, _createdAt);
}

abstract class TodoLabels {
  Iterable<Label> values();

  TodoLabels add(Label label);

  bool contains(label);
}

class TodoLabelsListImpl extends TodoLabels {
  final List<Label> _list;

  TodoLabelsListImpl(this._list);

  @override
  TodoLabels add(Label label) {
    var copied = _list.toList();
    copied.add(label);
    return TodoLabelsListImpl(copied);
  }

  @override
  Iterable<Label> values() => _list;

  @override
  bool contains(label) => _list.contains(label);
}

abstract class Status {
  Status start(DateTime startedAt);

  Status complete(DateTime completedAt);

  Status cancel(DateTime canceledAt);

  Status asNotStartedYet() => NotStarted();

  bool isCompleted();

  bool isCanceled();

  bool isInProgress();

  bool isFinished() {
    return this is Completed || this is Cancelled;
  }
}

class NotStarted extends Status {
  InProgress start(DateTime startedAt) => InProgress(startedAt);

  cancel(DateTime canceledAt) =>
      Cancelled(startedAt: canceledAt, cancelledAt: canceledAt);

  Completed complete(DateTime completedAt) =>
      Completed(startedAt: completedAt, completedAt: completedAt);

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => false;

  @override
  bool isInProgress() => false;
}

class InProgress extends Status {
  final DateTime startedAt;

  InProgress(this.startedAt);

  Completed complete(DateTime date) =>
      Completed(startedAt: startedAt, completedAt: date);

  Cancelled cancel(DateTime date) =>
      Cancelled(startedAt: startedAt, cancelledAt: date);

  Status start(_) => this;

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => false;

  @override
  bool isInProgress() => true;
}

class Completed extends Status {
  final DateTime startedAt;
  final DateTime completedAt;

  Completed({this.startedAt, this.completedAt});

  @override
  Status cancel(DateTime date) =>
      Cancelled(startedAt: startedAt, cancelledAt: date);

  @override
  Status complete(_) => this;

  @override
  Status start(_) => this;

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => true;

  @override
  bool isInProgress() => false;
}

class Cancelled extends Status {
  final DateTime startedAt;
  final DateTime cancelledAt;

  Cancelled({this.startedAt, this.cancelledAt});

  @override
  Status cancel(_) => this;

  @override
  Status complete(DateTime date) =>
      Completed(startedAt: startedAt, completedAt: date);

  @override
  Status start(_) => this;

  @override
  bool isCanceled() => true;

  @override
  bool isCompleted() => false;

  @override
  bool isInProgress() => false;
}

abstract class TodoCollection {
  Future<void> store(Todo todo);

  Future<Todo> get(ID<Todo> id);

  Future<List<Todo>> getByListID(ID<DailyTodoList> id);

  Future<List<Todo>> getAll();
}
