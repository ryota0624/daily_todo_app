import 'dart:async';

import 'package:daily_todo_app/event/event.dart';
import 'package:meta/meta.dart';

abstract class UseCaseResult {
  UseCaseResult(this.events);

  UseCaseResult.empty() : events = [];
  final List<Event> events;
}

mixin InputPort<I> {
  void put(I input);
}

mixin OutputPort<O> {
  void out(O output);
}

mixin EventOutputPort<O extends UseCaseResult>
on OutputPort<O>, WithEventPublisher {
  @override
  void out(O output) {
    output.events.forEach(eventPublisher.publish);
  }
}

mixin StreamOutputPresenter<O extends UseCaseResult> on EventOutputPort<O> {
  StreamSink<O> stream;

  @override
  void out(O output) {
    stream.add(output);
    super.out(output);
  }
}
mixin CallbackOutputPresenter<O extends UseCaseResult> on EventOutputPort<O> {
  void Function(O output) callback;

  @override
  void out(O output) {
    callback(output);
    super.out(output);
  }
}
mixin NoneOutputPort<O extends UseCaseResult> on EventOutputPort<O> {
  @override
  void out(O output) {
    super.out(output);
  }
}

abstract class UseCase<I, O extends UseCaseResult>
    with OutputPort<O>, WithEventPublisher, InputPort<I>, EventOutputPort<O> {
  @protected
  Future<O> execute(I input);

  Future<void> exec(I input) async {
    final output = await execute(input);
    super.out(output);
  }

  @override
  void put(I input) {
    exec(input);
  }
}
