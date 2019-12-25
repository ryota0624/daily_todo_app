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

  Container addT<T>(T component) {
    if (component.runtimeType.toString() == "_Type") {
      throw ContainerBuildError("component runtimeType=${component.runtimeType}");
    }
    _components.putIfAbsent(T, () => component);
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

  Container lazy<T>(T builder(R Function<R>() resolver)) {
    final componentFactory = _ComponentFactory<T>(() => builder(this.resolve));
    return add(T, componentFactory);
  }

  T resolve<T>() {
    final resolved = _components[T];

    if (resolved == null) {
      throw ContainerBuildError("component runtimeType=$T was not found");
    }

    if (resolved.runtimeType.toString().contains("_ComponentFactory")) {
      return resolved.create() as T;
    }

    return resolved as T;
  }

  List<Type> showAllRegistered() {
    return _components.keys.toList();
  }
}

class _ComponentFactory<T> {
  final T Function() create;

  _ComponentFactory(this.create);
}
