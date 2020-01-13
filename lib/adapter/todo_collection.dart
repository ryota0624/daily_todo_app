import 'package:daily_todo_app/todo.dart';

class TodoCollectionOnMap extends TodoCollection {
  Map<ID<Todo>, Todo> _map = Map.fromEntries([]);
  @override
  Future<Todo> get(ID<Todo> id) async => _map[id];


  @override
  Future<void> store(Todo todo) async {
    _map.addEntries([MapEntry(todo.id(), todo)]);
  }

  @override
  Future<List<Todo>> getAll() async {
    return _map.values.toList();
  }

  @override
  Future<List<Todo>> getByListID(ID<DailyTodoList> id) async {
    final all = await getAll();
    return all.where((todo) => todo.listID() == id).toList();
  }
}