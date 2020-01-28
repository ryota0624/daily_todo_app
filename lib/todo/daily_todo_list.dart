import 'package:daily_todo_app/todo/todo.dart';
import 'package:flutter/cupertino.dart';

class Date {
  const Date({this.year, this.month, this.day});
  Date.fromDateTime(DateTime date)
      :
        year = date.year,
        month = date.month,
        day = date.day;

  factory Date.today() {
    final now = DateTime.now();
    return Date.fromDateTime(now);
  }

  final int year;
  final int month;
  final int day;
  DateTime asDateTime() => DateTime(year, month, day);

}

class DailyTodoList {
  DailyTodoList({
    @required this.id,
    @required this.date,
  });
  final ID<DailyTodoList> id;
  final Date date;


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
