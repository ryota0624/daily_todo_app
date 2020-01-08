import 'dart:async';

import 'package:daily_todo_app/event/event.dart';
import 'package:meta/meta.dart';

abstract class UseCaseResult {
  final List<Event> events;

  UseCaseResult(this.events);

  UseCaseResult.empty(): this.events = [];

  UseCaseResult withEvents(List<Event> evs);

  R withEvent<R extends UseCaseResult>(Event e) =>
      withEvents([...this.events, ...[e]]);
}

mixin InputPort<I> {
  void put(I input);
}

mixin OutputPort<O> {
  out(O output);
}

mixin EventOutputPort<O extends UseCaseResult> on OutputPort<O>, WithEventPublisher {
  out(UseCaseResult output) {
    for (final evt in output.events) {
      eventPublisher.publish(evt);
    }
    out(output);
  }
}

mixin StreamOutputPresenter<O extends UseCaseResult> on EventOutputPort<O> {
  StreamSink<O> stream;

  @override
  out(O output) {
    stream.add(output);
    return null;
  }
}
mixin CallbackOutputPresenter<O  extends UseCaseResult> on EventOutputPort<O> {
  void Function(O output) callback;

  @override
  out(UseCaseResult output) {
    callback(output);
    return null;
  }
}
mixin NoneOutputPort<O extends UseCaseResult> on EventOutputPort<O> {
  @override
  out(UseCaseResult output) {
    return null;
  }
}

abstract class UseCase<I, O extends UseCaseResult> with OutputPort<O>, WithEventPublisher, InputPort<I>, EventOutputPort<O> {
  @protected
  Future<UseCaseResult> execute(I input);

  @override
  void put(I input) async {
    var output = await execute(input);
    super.out(output);
  }
}
