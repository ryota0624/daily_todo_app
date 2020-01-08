import 'package:daily_todo_app/todo/todo.dart';
import 'package:meta/meta.dart';

abstract class Event {
  final ID<DomainEvent> id = ID.create<DomainEvent>();
  final DateTime occurredAt = DateTime.now();
}

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
    print(evt);
    _eventlisteners.forEach((f) => f(evt));
    return null;
  }

  List _eventlisteners = []; // TODO マシな型づけ

  @override
  subscribe<E extends Event>(void Function(E evt) handler) {
    _eventlisteners.add(handler);
    return null;
  }
}

mixin EventSubscriber {
  subscribe<E extends Event>(void handler(E evt));
  // TODO unsubscribeの実装
}
