import 'package:daily_todo_app/widget/component_container.dart';
import 'package:test/test.dart';

abstract class ComponentA {
  int getInt();
}

class ComponentAImpl extends ComponentA {
  final int value;

  ComponentAImpl(this.value);

  int getInt() => value;
}

class ComponentB {
  final ComponentA a;

  ComponentB(this.a);

  String getMessage() => "componentA: ${a.getInt()}";
}

class NotFoundComponent {}

class GenericClass<A> {
  String getMessage() => "message";
}

abstract class AbstractGenericClass<A> {
  String getMessage();
}

class GenericClassImpl<A> extends AbstractGenericClass<A> {
  String getMessage() => "message2";
}

class GenericClassImplA extends GenericClassImpl<int> {
  String getMessage() => "message3";
}

void main() {
  final container = Container()
      .add(int, 100)
      .build<ComponentA>((resolver) => ComponentAImpl(resolver<int>()))
      .build<ComponentB>((resolver) => ComponentB(resolver<ComponentA>()));

  group("showAllRegistered", () {
    test("list", () {
      final registered = container.showAllRegistered();
      expect(registered, equals([int, ComponentA, ComponentB]));
    });
  });

  group("container.resolve", () {
    test("resolve primitive", () {
      final intValue = Container().add(int, 100).resolve<int>();
      expect(intValue, equals(100));
    });

    test("resolve abstract class", () {
      final componentA = container.resolve<ComponentA>();
      expect(componentA.runtimeType, ComponentAImpl);
    });

    test("resolve abstract class", () {
      final componentB = container.resolve<ComponentB>();
      expect(componentB.getMessage(), equals("componentA: 100"));
    });

    test("resolve generic class", () {
      final generic = container.addT<GenericClass<ComponentB>>(GenericClass()).resolve<GenericClass<ComponentB>>();
      expect(generic.getMessage(), equals("message"));
    });

    test("resolve abstract generic class", () {
      final generic = container.addT<AbstractGenericClass<int>>(GenericClassImplA()).resolve<AbstractGenericClass<int>>();
      expect(generic.getMessage(), equals("message3"));
    });
    
    test("called no register component", () {
      expect(() => container.resolve<NotFoundComponent>(), throwsA(TypeMatcher<ContainerBuildError>()));
    });
  });

  group("container.add", () {
    test("if duplicate type value add", () {
      final intValue = container.add(int, 200).resolve<int>();
      expect(intValue, equals(100));
    });

    test("if add argument 2 was Type", () {
      expect(() => container.add(int, int), throwsA(TypeMatcher<ContainerBuildError>()));
    });
  });

  group("container.lazy", () {
    test("if component had register by factory(), resolve method return every Returns a different value each time it is called", () {
      final c = Container().lazy<ComponentA>((r) => ComponentAImpl(200));
      final componentA1 = c.resolve<ComponentA>();
      final componentA2 = c.resolve<ComponentA>();
      expect(componentA1.hashCode, isNot(equals(componentA2.hashCode)));
    });
  });
}
