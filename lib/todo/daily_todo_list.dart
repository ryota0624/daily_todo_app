import 'package:daily_todo_app/todo/todo.dart';

class Date {
  final int year;
  final int month;
  final int day;

  Date({this.year, this.month, this.day});

  static fromDateTime(DateTime date) {
    return Date(year: date.year, month: date.month, day: date.day);
  }

  DateTime asDateTime() => DateTime(year, month, day);
}

class DailyTodoList {
  final Date _date;
  final List<Todo> _list;

  DailyTodoList(this._date, this._list);

  // 未達成を引きついで次の日のリストを作る
  DailyTodoList createNextDayTodoList() {
    var remainedTodos = _list.where((e) => !e.isFinished());
    return DailyTodoList(_date, remainedTodos);
  }

  factory DailyTodoList.initialize(Date date) {
    return DailyTodoList(date, []);
  }

  isAllTodoFinished() => _list.every((el) => el.isFinished());
}
