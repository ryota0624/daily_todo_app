class ContainerBuildError extends Error {
  ContainerBuildError(this.message);

  final String message;

  @override
  String toString() => message;
}

class Container {
  factory Container() {
    return Container._(Map<Type, dynamic>.identity());
  }

  Container._(this._components);

  Map<Type, dynamic> _components;

  Container _copy() => Container._(Map<Type, dynamic>.from(_components));

  Container add(Type t, dynamic component) {
    final copied = _copy();
    if (component.runtimeType.toString() == '_Type') {
      throw ContainerBuildError(
        'component runtimeType=${component.runtimeType}',
      );
    }
    copied._components.putIfAbsent(t, () => component);
    return copied;
  }

  Container addT<T>(T component) {
    final copied = _copy();

    if (component.runtimeType.toString() == '_Type') {
      throw ContainerBuildError(
        'component runtimeType=${component.runtimeType}',
      );
    }
    copied._components.putIfAbsent(T, () => component);
    return copied;
  }

  Container register<T>(T component) {
    final copied = _copy();
    copied._components.putIfAbsent(component.runtimeType, () => component);
    return copied;
  }

  Container build<T>(T Function(R Function<R>() resolver) builder) {
    final component = builder(resolve);
    return add(T, component);
  }

  Container lazy<T>(T Function(R Function<R>() resolver) builder) {
    final componentFactory = _ComponentFactory<T>(() => builder(resolve));
    return add(T, componentFactory);
  }

  T resolve<T>() {
    final dynamic resolved = _components[T];

    if (resolved == null) {
      throw ContainerBuildError('component runtimeType=$T was not found');
    }

    if (resolved.runtimeType.toString().contains('_ComponentFactory')) {
      return resolved.create() as T;
    }

    return resolved as T;
  }

  List<Type> showAllRegistered() {
    return _components.keys.toList();
  }
}

class _ComponentFactory<T> {
  _ComponentFactory(this.create);

  final T Function() create;
}
