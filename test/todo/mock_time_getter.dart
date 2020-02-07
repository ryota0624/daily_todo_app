import 'package:daily_todo_app/todo.dart';

class MockTimeGetter extends TimeGetter {
  MockTimeGetter(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
