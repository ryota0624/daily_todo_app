import 'package:daily_todo_app/todo/factory.dart'; // TODO: importをまとめたい
import 'package:daily_todo_app/todo/label.dart';
import 'package:daily_todo_app/todo/todo.dart';
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

class CreateTodo extends UseCase<CreateTodoParam, CreateTodoResult> {
  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;

  CreateTodo(
      {TodoFactory todoBuilder,
      TodoCollection todoCollection,
      OutputPort<CreateTodoResult> outputPort})
      : _todoCollection = todoCollection,
        _todoFactory = todoBuilder,
        super(outputPort);

  @override
  Future<OutputPortPerformed> execute(InputPort<CreateTodoParam> inputPort) async {
    var input = await inputPort.getSingleInput();
    Subject subject = Subject(input.subject);
    List<Label> labels = [];

    final todo =
        _todoFactory.create(subject: subject, labels: labels);

    await _todoCollection.store(todo);

    var output = CreateTodoResult(todo.id().toString());

    return outputPort.perform(output);
  }
}
