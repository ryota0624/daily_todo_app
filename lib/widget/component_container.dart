class Container {
  Map<Type, dynamic> _components;

  factory Container() {
    return Container._(Map.identity());
  }

  Container._(this._components);

  Container add(Type t, dynamic component) {
    _components.putIfAbsent(t, () => component);
    return this;
  }

  Container build<T>(T builder(R Function<R>() resolver)) {
    final component = builder(this.resolve);
    return add(T, component);
  }

  T resolve<T>() {
    return _components[T] as T;
  }
}
