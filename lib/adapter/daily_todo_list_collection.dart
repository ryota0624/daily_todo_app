import 'package:daily_todo_app/todo.dart';

class   DailyTodoListCollectionOnMap extends DailyTodoListCollection {
  final Map<ID<DailyTodoList>, DailyTodoList> _map = Map.fromEntries([]);

  @override
  Future<DailyTodoList> get(ID<DailyTodoList> id) async => _map[id];

  @override
  Future<void> store(DailyTodoList todo) async {
    _map.addEntries([MapEntry(todo.id, todo)]);
  }

  @override
  Future<List<DailyTodoList>> getAll() async {
    return _map.values.toList();
  }

  @override
  Future<DailyTodoList> getByDate(Date date) {
    return getAll().then((all) => all.firstWhere((list) => list.date == date));
  }
}
