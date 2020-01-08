import 'package:daily_todo_app/event/event.dart';

import 'todo.dart';

class TodoCreated extends DomainEvent {
  final ID<Todo> todoID;
  final Subject subject;

  TodoCreated(this.todoID, this.subject);
}

class TodoStatusChanged extends DomainEvent {
  final ID<Todo> todoID;
  final Status status;

  TodoStatusChanged(this.todoID, this.status);
}
