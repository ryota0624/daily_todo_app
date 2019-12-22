import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
class CreateTodoParam {
  final String subject;
  final List<String> labels;

  CreateTodoParam({this.subject, this.labels});
}

class CreateTodoResult {
  final String todoID;

  CreateTodoResult(this.todoID);
}

abstract class CreateTodoUseCase extends UseCase<CreateTodoParam, CreateTodoResult> {
  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;

  CreateTodoUseCase(this._todoFactory, this._todoCollection);

  @override
  Future<CreateTodoResult> execute(CreateTodoParam input) async {
    Subject subject = Subject(input.subject);
    List<Label> labels = [];
    final todo = _todoFactory.create(subject: subject, labels: labels);

    await _todoCollection.store(todo);

    return CreateTodoResult(todo.id().toString());
  }
}
