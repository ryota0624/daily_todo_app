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

void main() {
  final container = Container()
      .add(int, 100)
      .build<ComponentA>((resolver) => ComponentAImpl(resolver<int>()))
      .build<ComponentB>((resolver) => ComponentB(resolver<ComponentA>()));

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
}
