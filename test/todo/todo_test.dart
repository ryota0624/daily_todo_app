import 'package:daily_todo_app/todo.dart';
import 'package:test/test.dart';
import 'mock_time_getter.dart';

void main() {
  final dateTime = DateTime(2019);
  final factory =  TodoFactory(MockTimeGetter(dateTime), TodoLabelsFactoryImpl());
  Todo todo = factory.create(subject: Subject("test"), labels: []);

  group("complete()", () {
    final completed = todo.complete();
    test('isFinished return true', () async {
      expect(completed.isFinished(), equals(true));
    });
  });

  group("cancel()", () {
    final canceled = todo.cancel();
    test('isFinished return true', () async {
      expect(canceled.isFinished(), equals(true));
    });
  });

  group("changeSubject()", () {
    final newSubject = Subject("next");
    final subjectChanged = todo.changeSubject(newSubject);
    test("subject() is return Subject that taken by arguments", () {
      expect(subjectChanged.subject(), equals(newSubject));
    });
  });

  group("changeDescription()", () {
    final newDescription = TextDescription("next");
    final descriptionChanged = todo.changeDescription(newDescription);
    test("desciption() is return Description that taken by arguments", () {
      expect(descriptionChanged.description(), equals(newDescription));
    });
  });

  group("addLabel()", () {
    final newLabel = Label("next");
    final addedLabel = todo.addLabel(newLabel);
    test("labels() is return Labels that is contains added label", () {
      expect(addedLabel.hasLabel(newLabel), equals(true));
    });
  });
}
