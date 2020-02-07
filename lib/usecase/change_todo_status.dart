import 'package:daily_todo_app/errors/enum_error.dart';
import 'package:daily_todo_app/event/event.dart';
import 'package:daily_todo_app/todo.dart';
import 'package:daily_todo_app/todo/event.dart';
import 'package:daily_todo_app/usecase/usecase.dart';
import 'package:flutter/cupertino.dart';

enum ChangeTodoStatus { reverseNotStartedYet, start, complete, cancel }

class ChangeTodoStatusParam {
  ChangeTodoStatusParam({
    @required this.todoID,
    @required this.status,
  });

  final ID<Todo> todoID;

  final ChangeTodoStatus status;
}

class ChangeTodoStatusResult extends UseCaseResult {
  ChangeTodoStatusResult(this.todoID, this.status, List<Event> events)
      : super(events);

  final String todoID;
  final Status status;
}

abstract class ChangeTodoStatusUseCase
    extends UseCase<ChangeTodoStatusParam, ChangeTodoStatusResult> {
  ChangeTodoStatusUseCase(
    this._todoCollection,
    this._timeGetter,
  );

  final TodoCollection _todoCollection;
  final TimeGetter _timeGetter;

  @override
  Future<ChangeTodoStatusResult> execute(ChangeTodoStatusParam input) async {
    final todo = await _todoCollection.get(input.todoID);

    WithEvent<TodoStatusChanged, Todo> changed;
    switch (input.status) {
      case ChangeTodoStatus.complete:
        changed = todo.complete(_timeGetter.now());
        break;
      case ChangeTodoStatus.cancel:
        changed = todo.cancel(_timeGetter.now());
        break;
      case ChangeTodoStatus.reverseNotStartedYet:
        changed = todo.asNotStartedYet();
        break;
      case ChangeTodoStatus.start:
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
