import 'dart:async';

import 'package:meta/meta.dart';

abstract class InputPort<I> {
  void put(I input);
  Stream<I> getInput();
  Future<I> getSingleInput() => getInput().single;
}

class InputPortImpl<T> extends InputPort<T> {
  T _putValue;
  @override
  void put(T input) {
    _putValue = input;
  }
  @override
  Stream<T> getInput() {
    return Stream.value(_putValue);
  }
}

abstract class OutputPort<O> {
  execute(O output);
  OutputPortPerformed perform(O output) {
    execute(output);
    return OutputPortPerformed();
  }
}

class NoneOutputPort<O> extends OutputPort<O> {
  @override
  execute(O output) {
    return null;
  }
}

class OutputPortPerformed {}

abstract class UseCase<I, O> {
  @protected final OutputPort<O> outputPort;
  UseCase(this.outputPort);
  Future<OutputPortPerformed> execute(InputPort<I> inputPort);
}
