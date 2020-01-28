import 'dart:math';

import 'package:daily_todo_app/todo/todo.dart';
import 'package:meta/meta.dart';

abstract class Event {
  final ID<DomainEvent> id = ID.create<DomainEvent>();
  final DateTime occurredAt = DateTime.now();
}

abstract class UiEvent extends Event {}

abstract class DomainEvent extends Event {}

class WithEvent<E extends DomainEvent, Other> {
  final E event;
  final Other result;

  WithEvent(this.event, this.result);
}

mixin WithEventPublisher {
  @protected
  EventPublisher get eventPublisher;
}

mixin WithEventSubscriber {
  @protected
  EventSubscriber get eventSubscriber;
}

mixin MixinEventPublisher implements WithEventPublisher {
  @override
  EventPublisher get eventPublisher => MixinEventPublisher._publisher;

  static final _publisher = EventPublisherImpl();
}

mixin MixinEventSubscriber implements WithEventSubscriber {
  @override
  EventSubscriber get eventSubscriber => MixinEventPublisher._publisher;
}

mixin EventPublisher {
  Future<void> publish<E extends Event>(E evt);
}

class EventPublisherImpl with EventPublisher, EventSubscriber {
  @override
  Future<void> publish<E extends Event>(E evt) {
    _eventListeners.forEach((_, dynamic f) => f(evt));
    return null;
  }

  static final _rand = Random.secure();

  final Map<SubscribeID, dynamic> _eventListeners =
      Map<SubscribeID, dynamic>.identity(); // TODO(ryota0624): マシな型づけ

  @override
  SubscribeID subscribe<E extends Event>(void Function(E evt) handler) {
    final id = SubscribeID(_rand.nextDouble().toString());
    _eventListeners[id] = handler;
    return null;
  }

  @override
  void remove(SubscribeID id) {
    _eventListeners.remove(id);
  }
}

class SubscribeID {
  final String _value;

  SubscribeID(this._value);

  @override
  bool operator ==(dynamic other) {
    if (other is SubscribeID) {
      return other._value == _value;
    }
    return false;
  }

  @override
  int get hashCode => _value.hashCode;
}

mixin EventSubscriber {
  SubscribeID subscribe<E extends Event>(void Function(E) handler);

  void remove(SubscribeID id);
}
