import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:meta/meta.dart';

class CreateTodoParam {
  final String subject;
  final List<String> labels;

  CreateTodoParam({this.subject, this.labels});
}

class CreateTodoResult {
  final String todoID;

  CreateTodoResult(this.todoID);
}

class CreateTodo extends UseCase<CreateTodoParam, CreateTodoResult> {
  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;

  CreateTodo(
      {@required TodoFactory todoFactory,
      @required TodoCollection todoCollection,
      @required OutputPort<CreateTodoResult> outputPort})
      : _todoCollection = todoCollection,
        _todoFactory = todoFactory,
        super(outputPort);

  @override
  Future<OutputPortPerformed> execute(
      InputPort<CreateTodoParam> inputPort) async {
    var input = await inputPort.getSingleInput();
    Subject subject = Subject(input.subject);
    List<Label> labels = [];

    final todo = _todoFactory.create(subject: subject, labels: labels);

    await _todoCollection.store(todo);

    var output = CreateTodoResult(todo.id().toString());

    return outputPort.perform(output);
  }
}
