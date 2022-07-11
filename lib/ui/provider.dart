import 'package:flutter/material.dart';

class ChangeNotifierProvider<T extends ChangeNotifier>
    extends InheritedNotifier<T> {
  const ChangeNotifierProvider({
    Key? key,
    required T model,
    required Widget child,
  }) : super(
    key: key,
    notifier: model,
    child: child,
  );
}

extension WatchContext on BuildContext {
  T? watch<T extends ChangeNotifier>() {
    return dependOnInheritedWidgetOfExactType<ChangeNotifierProvider<T>>()
        ?.notifier;
  }
}

extension ReadContext on BuildContext {
  T? read<T extends ChangeNotifier>() {
    final widget =
        getElementForInheritedWidgetOfExactType<ChangeNotifierProvider<T>>()
            ?.widget;
    return (widget is ChangeNotifierProvider<T>)
        ? widget.notifier
        : null;
  }
}