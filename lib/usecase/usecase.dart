import 'dart:async';

abstract class InputPort<I> {
  put(I input);
  Stream<I> getInput();
  Future<I> getSingleInput() => getInput().single;
}

abstract class OutputPort<O> {}

abstract class UseCase<I, O> {
  final OutputPort<O> outputPort;
  UseCase(this.outputPort);
  execute(InputPort<I> inputPort);
}