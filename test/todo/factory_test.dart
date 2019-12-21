import 'package:daily_todo_app/todo.dart';
import 'package:test/test.dart';
import 'mock_time_getter.dart';

void main() {
  group("create", () {
    final dateTime = DateTime(2019);
    final factory =
        TodoFactory(MockTimeGetter(dateTime), TodoLabelsFactoryImpl());
    final labels = [Label("Home"), Label("ASAP")];
    final subject = Subject("cleaning toilet");
    final todo = factory.create(subject: subject, labels: labels);

    test("todo has subject that as same as arguments", () {
      expect(todo.subject(), equals(subject));
    });

    test("todo has labels that has equal element with arguments", () {
      expect(todo.labels().values().toList(), equals(labels.toList()));
    });

    test("todo is not finished", () {
      expect(todo.isFinished(), equals(false));
    });

    test("description is Empty", () {
      expect(todo.description().runtimeType,
          equals(EmptyDescription().runtimeType));
      expect(todo.description().isEmpty(), equals(true));
    });
  });
}
