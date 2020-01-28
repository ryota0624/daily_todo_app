import 'package:daily_todo_app/event/event.dart';

import 'daily_todo_list.dart';
import 'todo.dart';


class TodoCreated extends DomainEvent {
  TodoCreated(this.todoID, this.subject);

  final ID<Todo> todoID;
  final Subject subject;

}

class TodoStatusChanged extends DomainEvent {
  TodoStatusChanged(this.todoID, this.status);

  final ID<Todo> todoID;
  final Status status;

}

class DailyTodoListCreated extends DomainEvent {
  DailyTodoListCreated(this.listID, this.date);

  final ID<DailyTodoList> listID;
  final Date date;

}
class DailyTodoListClosed extends DomainEvent {
  DailyTodoListClosed(this.listID, this.date);

  final ID<DailyTodoList> listID;
  final Date date;

}