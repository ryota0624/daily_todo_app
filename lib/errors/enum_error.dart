class InvalidEnumArgumentException<E> extends ArgumentError {
  InvalidEnumArgumentException(E invalidValue) : super(invalidValue.toString());
}