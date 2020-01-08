import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';

class CreateTodoParam {
  final String subject;
  final List<String> labels;

  CreateTodoParam({this.subject, this.labels});
}

class CreateTodoResult extends UseCaseResult {
  final String todoID;

  CreateTodoResult(this.todoID, List<Event> events) : super(events);

  @override
  CreateTodoResult withEvents(List<Event> evs) =>
      CreateTodoResult(this.todoID, [...this.events, ...evs]);
}

abstract class CreateTodoUseCase
    extends UseCase<CreateTodoParam, CreateTodoResult> {
  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;

  CreateTodoUseCase(
      this._todoFactory, this._todoCollection);

  @override
  Future<CreateTodoResult> execute(CreateTodoParam input) async {
    Subject subject = Subject(input.subject);
    List<Label> labels = [];
    final created = _todoFactory.create(subject: subject, labels: labels);

    await _todoCollection.store(created.result);

    return CreateTodoResult(created.result.id().toString(), [created.event]);
  }
}
