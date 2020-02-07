import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/cupertino.dart';

class CreateTodoParam {
  CreateTodoParam({
    this.listID,
    @required this.subject,
    @required this.labels,
  });

  final ID<DailyTodoList> listID;
  final String subject;
  final List<String> labels;
}

class CreateTodoResult extends UseCaseResult {
  CreateTodoResult(this.todoID, List<Event> events) : super(events);
  final String todoID;
}

abstract class CreateTodoUseCase
    extends UseCase<CreateTodoParam, CreateTodoResult> {
  CreateTodoUseCase(this._todoFactory, this._todoCollection);

  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;

  @override
  Future<CreateTodoResult> execute(CreateTodoParam input) async {
    var listID = input.listID;
    listID ??= ID.create(); // CreateTodoList

    final subject = Subject(input.subject);
    final labels = <Label>[];
    final created = _todoFactory.create(
        subject: subject, labels: labels, listID: input.listID);

    await _todoCollection.store(created.result);

    return CreateTodoResult(created.result.id().toString(), [created.event]);
  }
}
