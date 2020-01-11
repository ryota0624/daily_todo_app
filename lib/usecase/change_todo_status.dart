import 'package:daily_todo_app/errors/enum_error.dart';
import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/cupertino.dart';

enum ChangeTodoStatus { ReverseNotStartedYet, Start, Complete, Cancel }

class ChangeTodoStatusParam {
  final ID<Todo> todoID;

  final ChangeTodoStatus status;

  ChangeTodoStatusParam({
    @required this.todoID,
    @required this.status,
  });
}

class ChangeTodoStatusResult extends UseCaseResult {
  final String todoID;
  final Status status;

  ChangeTodoStatusResult(this.todoID, this.status, List<Event> events)
      : super(events);

  @override
  ChangeTodoStatusResult withEvents(List<Event> evs) => ChangeTodoStatusResult(
        this.todoID,
        this.status,
        [...this.events, ...evs],
      );
}

abstract class ChangeTodoStatusUseCase
    extends UseCase<ChangeTodoStatusParam, ChangeTodoStatusResult> {
  final TodoCollection _todoCollection;
  final TimeGetter _timeGetter;

  ChangeTodoStatusUseCase(
    this._todoCollection,
    this._timeGetter,
  );

  @override
  Future<ChangeTodoStatusResult> execute(ChangeTodoStatusParam input) async {
    Todo todo = await _todoCollection.get(input.todoID);

    WithEvent<TodoStatusChanged, Todo> changed;
    switch (input.status) {
      case ChangeTodoStatus.Complete:
        changed = todo.complete(_timeGetter.now());
        break;
      case ChangeTodoStatus.Cancel:
        changed = todo.cancel(_timeGetter.now());
        break;
      case ChangeTodoStatus.ReverseNotStartedYet:
        changed = todo.asNotStartedYet();
        break;
      case ChangeTodoStatus.Start:
        changed = todo.start(_timeGetter.now());
        break;
      default:
        throw InvalidEnumArgumentException(input.status);
    }

    await _todoCollection.store(changed.result);

    return ChangeTodoStatusResult(
      changed.result.id().toString(),
      changed.result.status(),
      [changed.event],
    );
  }
}
