import 'package:daily_todo_app/todo/todo.dart';
import 'package:flutter/cupertino.dart';

class Date {
  final int year;
  final int month;
  final int day;

  Date({this.year, this.month, this.day});

  static fromDateTime(DateTime date) {
    return Date(year: date.year, month: date.month, day: date.day);
  }

  DateTime asDateTime() => DateTime(year, month, day);

  factory Date.today() {
    final now = DateTime.now();
    return Date.fromDateTime(now);
  }
}

class DailyTodoList {
  final ID<DailyTodoList> id;

  final Date date;


  DailyTodoList({
    @required this.id,
    @required this.date,
  });

//  // DomainService 未達成を引きついで次の日のリストを作る
//  DailyTodoList createNextDayTodoList(Todos todos) {
//    return DailyTodoList(_date, Todos(todos.selectNotFinished()));
//  }
//
//  DailyTodoList addTodo(Todo todo) => DailyTodoList(_date, _todos.put(todo));
//  DailyTodoList modifyTodo(Todo todo) => DailyTodoList(_date, _todos.put(todo));
//
//  bool isAllTodoFinished() => _todos.isAllFinished();
}

abstract class DailyTodoListCollection {
  Future<void> store(DailyTodoList todo);

  Future<DailyTodoList> get(ID<DailyTodoList> id);
  Future<DailyTodoList> getByDate(Date date);

  Future<List<DailyTodoList>> getAll();
}
