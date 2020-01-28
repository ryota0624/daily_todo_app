import 'package:daily_todo_app/todo.dart';
import 'package:flutter/widgets.dart';

abstract class NavigationService {
  Future push(NavigationRoute route);

  bool pop();
}

mixin NavigationRoute {
  String name();
}

class DailyTodosRoute with NavigationRoute {
  final Date date;

  DailyTodosRoute(this.date);

  @override
  String name() => "daily_todos";
}

class TodoDetail with NavigationRoute {
  final ID<Todo> todoID;

  TodoDetail(this.todoID);

  @override
  String name() => "todos_detail";
}

class NavigationServiceImpl extends NavigationService {
  final GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigationKey.currentState;

  @override
  Future push(NavigationRoute route) {
    return _navigator.pushNamed(
      route.name(),
      arguments: route,
    );
  }

  bool pop() {
    return _navigator.pop();
  }
}

typedef _RouteWidgetBuilder<Route extends NavigationRoute> = Widget Function(
    Route);

class RouteWidgetBuilder<Route extends NavigationRoute> {
  final _RouteWidgetBuilder<Route> _build;

  RouteWidgetBuilder._(this._build);

  Widget build(Route route) => _build(route);

  static RouteWidgetBuilder<Route> route<Route extends NavigationRoute>(
      Widget Function(Route) build,) =>
      RouteWidgetBuilder._(build);
}

Widget Function(RouteSettings) onGenerateRoute(
    List<RouteWidgetBuilder> builders,) {
  return (RouteSettings routeSettings) {
    String _routeWidgetBuilderType(NavigationRoute route) =>
        "RouteWidgetBuilder<${route.runtimeType.toString()}>";

    if (routeSettings.arguments is NavigationRoute) {
      final route = routeSettings.arguments as NavigationRoute;
      final matchedBuilder = builders.firstWhere((RouteWidgetBuilder builder) =>
      builder.runtimeType.toString() == _routeWidgetBuilderType(route));

      if (matchedBuilder != null) {
        return matchedBuilder.build(route);
      }
    }

    // いい感じエラーを投げる
    // 1. Matchするbuilderがいなかった
    // 2. argumentsがrouteじゃなかった。
    throw Error();
  };
}