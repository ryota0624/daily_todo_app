import 'dart:async';

import 'package:meta/meta.dart';

mixin InputPort<I> {
  void put(I input);
}

mixin OutputPort<O> {
  out(O output);
}

mixin StreamOutputPort<O> on OutputPort<O> {
  StreamSink<O> stream;

  @override
  out(O output) {
    stream.add(output);
    return null;
  }
}
mixin CallbackOutputPort<O> on OutputPort<O> {
  void Function(O output) callback;
  @override
  out(O output) {
    callback(output);
    return null;
  }
}
mixin NoneOutputPort<O> on OutputPort<O> {
  @override
  out(O output) {
    return null;
  }
}

abstract class UseCase<I, O> with InputPort<I>, OutputPort<O> {
  @protected
  Future<O> execute(I input);

  @override
  void put(I input) async {
    var output = await execute(input);
    out(output);
  }
}
