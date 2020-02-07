abstract class Option<E> {
  E getOrException();

  D match<D>({
    D Function(E) some,
    D Function() none,
  });

}

Option<E> option<E>(E value) {
  if (value == null) {
    return None();
  }

  return Some(value);
}

class None<O> extends Option<O> {
  @override
  O getOrException() {
    throw StateError('option value is none');
  }

  @override
  D match<D>({D Function(O) some, D Function() none}) => none();
}

class Some<E> extends Option<E> {
  Some(this._value);

  final E _value;

  @override
  E getOrException() => _value;

  @override
  D match<D>({D Function(E) some, D Function() none}) => some(_value);
}
