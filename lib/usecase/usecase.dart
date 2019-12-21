import 'dart:async';

import 'package:meta/meta.dart';

abstract class InputPort<I> {
  put(I input);
  Stream<I> getInput();
  Future<I> getSingleInput() => getInput().single;
}

abstract class OutputPort<O> {
  execute(O output);
  OutputPortPerformed perform(O output) {
    execute(output);
    return OutputPortPerformed();
  }
}

class OutputPortPerformed {}

abstract class UseCase<I, O> {
  @protected final OutputPort<O> outputPort;
  UseCase(this.outputPort);
  Future<OutputPortPerformed> execute(InputPort<I> inputPort);
}