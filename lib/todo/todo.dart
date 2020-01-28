import 'dart:math';

import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/todo/label.dart';

class ID<E> {
  ID._(this._str);

  factory ID.fromString(String str) => ID._(str);

  factory ID.create() => ID.fromString(
    Random(999).nextDouble().toString(),
  );

  final String _str;

  @override
  String toString() => _str;

}

class Subject {
  Subject(this._text);

  final String _text;

  @override
  String toString() => _text;
}

// ignore: one_member_abstracts
abstract class Description {
  bool isEmpty();
}

class TextDescription extends Description {
  TextDescription(this._text);

  final String _text;

  @override
  bool isEmpty() => _text.isEmpty;
}

class EmptyDescription extends Description {
  @override
  bool isEmpty() => true;
}

class Todos {
  Todos(this._values);

  factory Todos.empty() => Todos([]);

  final List<Todo> _values;

  Todos put(Todo t) => Todos([..._values.where((t2) => t2.id() != t.id()), t]);

  List<Todo> selectCompleted() =>
      _values.where((todo) => todo.isCompleted()).toList();

  List<Todo> selectCanceled() =>
      _values.where((todo) => todo.isCanceled()).toList();

  List<Todo> selectNotFinished() =>
      _values.where((todo) => !todo.isFinished()).toList();

  bool isAllFinished() {
    return selectNotFinished().isEmpty && selectCompleted().length > 1;
  }
}

class Todo {
  Todo(this._id, this._listID, this._labels, this._subject, this._description,
      this._status, this._createdAt);

  final ID<Todo> _id;
  final ID<DailyTodoList> _listID;
  final TodoLabels _labels;
  final Subject _subject;
  final Description _description;
  final Status _status;
  final DateTime _createdAt;

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

  bool contains(Label label);
}

class TodoLabelsListImpl extends TodoLabels {
  TodoLabelsListImpl(this._list);

  final List<Label> _list;

  @override
  TodoLabels add(Label label) {
    final copied = _list.toList()..add(label);
    return TodoLabelsListImpl(copied);
  }

  @override
  Iterable<Label> values() => _list;

  @override
  bool contains(Label label) => _list.contains(label);
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
  @override
  InProgress start(DateTime startedAt) => InProgress(startedAt);

  @override
  Status cancel(DateTime canceledAt) =>
      Cancelled(startedAt: canceledAt, cancelledAt: canceledAt);

  @override
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
  InProgress(this.startedAt);

  final DateTime startedAt;

  @override
  Completed complete(DateTime completedAt) =>
      Completed(startedAt: startedAt, completedAt: completedAt);

  @override
  Cancelled cancel(DateTime canceledAt) =>
      Cancelled(startedAt: startedAt, cancelledAt: canceledAt);

  @override
  Status start(DateTime startedAt) => this;

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => false;

  @override
  bool isInProgress() => true;
}

class Completed extends Status {
  Completed({this.startedAt, this.completedAt});

  final DateTime startedAt;
  final DateTime completedAt;

  @override
  Status cancel(DateTime canceledAt) =>
      Cancelled(startedAt: startedAt, cancelledAt: canceledAt);

  @override
  Status complete(DateTime completedAt) => this;

  @override
  Status start(DateTime startedAt) => this;

  @override
  bool isCanceled() => false;

  @override
  bool isCompleted() => true;

  @override
  bool isInProgress() => false;
}

class Cancelled extends Status {
  Cancelled({this.startedAt, this.cancelledAt});

  final DateTime startedAt;
  final DateTime cancelledAt;

  @override
  Status cancel(DateTime canceledAt) => this;

  @override
  Status complete(DateTime completedAt) =>
      Completed(startedAt: startedAt, completedAt: completedAt);

  @override
  Status start(DateTime startedAt) => this;

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
