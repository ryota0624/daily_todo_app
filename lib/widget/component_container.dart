class ContainerBuildError extends Error {
  final String message;
  ContainerBuildError(this.message);

  String toString() => message;

}

class Container {
  Map<Type, dynamic> _components;

  factory Container() {
    return Container._(Map.identity());
  }

  Container._(this._components);

  Container add(Type t, dynamic component) {
    if (component.runtimeType.toString() == "_Type") {
      throw ContainerBuildError("component runtimeType=${component.runtimeType}");
    }
    _components.putIfAbsent(t, () => component);
    return this;
  }

  Container register(dynamic component) {
    _components.putIfAbsent(component.runtimeType, () => component);
    return this;
  }

  Container build<T>(T builder(R Function<R>() resolver)) {
    final component = builder(this.resolve);
    return add(T, component);
  }

  T resolve<T>() {
    final resolved = _components[T] as T;
    if (resolved == null) {
      throw ContainerBuildError("component runtimeType=$T was not found");
    }

    return resolved;
  }
}
