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
      _AlertMessengerScope scope = _AlertMessengerScope.of(context);
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

  final GroupAlertsByValue _groupAlertsByValue = GroupAlertsByValue();

  Widget? alertWidget;
  AlertPriority? typeAlertPriority;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final alertHeight = MediaQuery.paddingOf(context).top + kAlertHeight;
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
    _verifyIfHasAlerts(newAlert: alert);
  }

  void hideAlert() {
    _groupAlertsByValue.deleteTheMostImportantAlert();
    controller.reverse().whenComplete(() {
      setState(() => typeAlertPriority = null);
      _verifyIfHasAlerts();
    });
  }

  void _verifyIfHasAlerts({Alert? newAlert}) {
    Alert? alert = _groupAlertsByValue.nextAlert;
    _saveAlert(newAlert);

    if (alert == null && newAlert != null) {
      _setToShowAlertWithAnimation(alert: newAlert);
    } else if (alert != null && newAlert == null) {
      _setToShowAlertWithAnimation(alert: alert);
    } else if (alert != null && newAlert != null && newAlert.priority.value == alert.priority.value) {
      _setToShowAlertWithAnimation(alert: alert);
    } else if (alert != null && newAlert != null && newAlert.priority.value > alert.priority.value) {
      _setToShowAlertWithAnimation(alert: newAlert);
    }
  }

  void _setToShowAlertWithAnimation({required Alert alert}) {
    controller.reverse().whenComplete(() {
      setState(() {
        alertWidget = alert;
        typeAlertPriority = alert.priority;
      });
      controller.forward();
    });
  }

  void _saveAlert(Alert? alert) {
    if (alert != null) {
      switch (alert.priority.value) {
        case 2:
          _groupAlertsByValue.listError.add(alert);
        case 1:
          _groupAlertsByValue.listWarning.add(alert);
        case 0:
          _groupAlertsByValue.listInfo.add(alert);
      }
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
  bool updateShouldNotify(_AlertMessengerScope oldWidget) => true;

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

  bool get listErrorIsNotEmpty => listError.isNotEmpty;

  bool get listWarningIsNotEmpty => listWarning.isNotEmpty;

  bool get listInfoIsNotEmpty => listInfo.isNotEmpty;

  Alert? get nextAlert {
    Alert? alert;

    if (listErrorIsNotEmpty) {
      alert = listError.first;
    } else if (listWarningIsNotEmpty) {
      alert = listWarning.first;
    } else if (listInfoIsNotEmpty) {
      alert = listInfo.first;
    }
    return alert;
  }

  void deleteTheMostImportantAlert() {
    if (listErrorIsNotEmpty) {
      listError.remove(listError.first);
    } else if (listWarningIsNotEmpty) {
      listWarning.remove(listWarning.first);
    } else if (listInfoIsNotEmpty) {
      listInfo.remove(listInfo.first);
    }
  }
}
