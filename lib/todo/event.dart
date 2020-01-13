import 'package:daily_todo_app/event/event.dart';

import 'daily_todo_list.dart';
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

class DailyTodoListCreated extends DomainEvent {
  final ID<DailyTodoList> listID;
  final Date date;

  DailyTodoListCreated(this.listID, this.date);
}
class DailyTodoListClosed extends DomainEvent {
  final ID<DailyTodoList> listID;
  final Date date;

  DailyTodoListClosed(this.listID, this.date);
}