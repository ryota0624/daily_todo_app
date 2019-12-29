import 'todo.dart';

abstract class Collection<Item> {
  Future<void> store(Item item);
  Future<Item> get(ID<Item> id);
  Future<List<Item>> getAll();
}