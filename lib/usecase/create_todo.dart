import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/cupertino.dart';

class CreateTodoParam {
  final ID<DailyTodoList> listID;
  final String subject;
  final List<String> labels;

  CreateTodoParam({
    @required this.listID,
    @required this.subject,
    @required this.labels,
  });
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
  CreateTodoUseCase(this._todoFactory, this._todoCollection);

  final TodoFactory _todoFactory;
  final TodoCollection _todoCollection;


  @override
  Future<CreateTodoResult> execute(CreateTodoParam input) async {
    final subject = Subject(input.subject);
    final labels = <Label>[];
    final created = _todoFactory.create(
        subject: subject, labels: labels, listID: input.listID);

    await _todoCollection.store(created.result);

    return CreateTodoResult(created.result.id().toString(), [created.event]);
  }
}
