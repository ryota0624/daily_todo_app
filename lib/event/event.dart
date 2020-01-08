import 'package:daily_todo_app/todo/todo.dart';
import 'package:meta/meta.dart';

abstract class Event {
  final ID<DomainEvent> id = ID.create<DomainEvent>();
  final DateTime occurredAt = DateTime.now();
}

abstract class DomainEvent extends Event {
}

class WithEvent<E extends DomainEvent, Other> {
  final E event;
  final Other result;

  WithEvent(this.event, this.result);
}

mixin WithEventPublisher {
  @protected EventPublisher get eventPublisher;
}

mixin MixinEventPublisher implements WithEventPublisher {
  @override
  EventPublisher get eventPublisher => EventPublisherImpl();
}

mixin EventPublisher {
  Future<void> publish<E extends Event>(E evt);
}

class EventPublisherImpl with EventPublisher {
  @override
  Future<void> publish<E extends Event>(E evt) {
    print(evt);
    // TODO: implement publish
    return null;
  }
}

mixin EventSubscriber {
  subscribe<E extends Event>(void handler(E evt));
}
