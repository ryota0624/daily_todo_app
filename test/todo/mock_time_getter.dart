import 'package:daily_todo_app/todo.dart';

class MockTimeGetter extends TimeGetter {
  final DateTime _now;

  MockTimeGetter(this._now);

  @override
  DateTime now() => _now;
}
