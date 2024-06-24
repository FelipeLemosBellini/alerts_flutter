import 'package:flutter/material.dart';

const kAlertHeight = 80.0;

enum AlertPriority {
  error(2),
  warning(1),
  info(0);

  const AlertPriority(this.value);

  final int value;
}

class Alert extends StatelessWidget {
  const Alert({
    super.key,
    required this.backgroundColor,
    required this.child,
    required this.leading,
    required this.priority,
  });

  final Color backgroundColor;
  final Widget child;
  final Widget leading;
  final AlertPriority priority;

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.paddingOf(context).top;
    return Material(
        child: Ink(
            color: backgroundColor,
            height: kAlertHeight + statusbarHeight,
            child: Column(children: [
              SizedBox(height: statusbarHeight),
              Expanded(
                  child: Row(children: [
                const SizedBox(width: 28.0),
                IconTheme(
                  data: const IconThemeData(
                    color: Colors.white,
                    size: 36,
                  ),
                  child: leading,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                    child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: child,
                ))
              ])),
              const SizedBox(width: 28.0),
            ])));
  }
}

class AlertMessenger extends StatefulWidget {
  const AlertMessenger({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AlertMessenger> createState() => AlertMessengerState();

  static AlertMessengerState of(BuildContext context) {
    try {
      final scope = _AlertMessengerScope.of(context);
      return scope.state;
    } catch (error) {
      throw FlutterError.fromParts(
        [
          ErrorSummary('No AlertMessenger was found in the Element tree'),
          ErrorDescription('AlertMessenger is required in order to show and hide alerts.'),
          ...context.describeMissingAncestor(expectedAncestorType: AlertMessenger),
        ],
      );
    }
  }
}

class AlertMessengerState extends State<AlertMessenger> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  Widget? alertWidget;
  GroupAlertsByValue _groupAlertsByValue = GroupAlertsByValue();

  bool isShowingTheAlert = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _verifyOtherAlerts();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final alertHeight = MediaQuery.of(context).padding.top + kAlertHeight;
    animation = Tween<double>(begin: -alertHeight, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showAlert({required Alert alert}) {
    if (isShowingTheAlert) {
      _saveAlert(alert);
    } else {
      setState(() => alertWidget = alert);
      isShowingTheAlert = true;
    }
    controller.forward();
  }

  void hideAlert() {
    isShowingTheAlert = false;

    controller.reverse();
  }

  void _verifyOtherAlerts() {
    Alert? alert;
    alert = _groupAlertsByValue.nextAlert();
    if (alert != null) {
      showAlert(alert: alert);
    }
  }

  void _saveAlert(Alert alert) {
    if (alert.priority.value == 2) {
      _groupAlertsByValue.listError.add(alert);
    } else if (alert.priority.value == 1) {
      _groupAlertsByValue.listWarning.add(alert);
    } else {
      _groupAlertsByValue.listInfo.add(alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusbarHeight = MediaQuery.paddingOf(context).top;

    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final position = animation.value + kAlertHeight;
          return Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [
            Positioned.fill(
                top: position <= statusbarHeight ? 0 : position - statusbarHeight,
                child: _AlertMessengerScope(
                  state: this,
                  child: widget.child,
                )),
            Positioned(top: animation.value, left: 0, right: 0, child: alertWidget ?? const SizedBox.shrink())
          ]);
        });
  }
}

class _AlertMessengerScope extends InheritedWidget {
  const _AlertMessengerScope({
    required this.state,
    required super.child,
  });

  final AlertMessengerState state;

  @override
  bool updateShouldNotify(_AlertMessengerScope oldWidget) => state != oldWidget.state;

  static _AlertMessengerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AlertMessengerScope>();
  }

  static _AlertMessengerScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No _AlertMessengerScope found in context');
    return scope!;
  }
}

class GroupAlertsByValue {
  List<Alert> listError = [];
  List<Alert> listWarning = [];
  List<Alert> listInfo = [];

  GroupAlertsByValue();

  bool get listErrorIsEmpty => listError.isEmpty;

  bool get listWarningIsEmpty => listWarning.isEmpty;

  bool get listInfoIsEmpty => listInfo.isEmpty;

  Alert? nextAlert() {
    Alert? alert;

    if (!listErrorIsEmpty) {
      alert = listError.first;
      listError.remove(listError.first);
    } else if (!listWarningIsEmpty) {
      alert = listWarning.first;
      listWarning.remove(listWarning.first);
    } else if (!listInfoIsEmpty) {
      alert = listInfo.first;
      listInfo.remove(listInfo.first);
    }
    return alert;
  }
}
