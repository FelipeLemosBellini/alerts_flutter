import 'package:flutter/material.dart';

import 'alert_messenger.dart';

void main() => runApp(const AlertPriorityApp());

class AlertPriorityApp extends StatelessWidget {
  const AlertPriorityApp({super.key});

  String get textErrorAlert => 'Oops, ocorreu um erro. Pedimos desculpas.';

  String get textWarningAlert => 'Atenção! Você foi avisado.';

  String get textInfoAlert => 'Este é um aplicativo escrito em Flutter.';

  String setTextAlert(AlertPriority? alert) {
    if (alert != null) {
      switch (alert) {
        case AlertPriority.error:
          return textErrorAlert;
        case AlertPriority.warning:
          return textWarningAlert;
        case AlertPriority.info:
          return textErrorAlert;
      }
    } else {
      return "Não há alertas para exibir";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Priority',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            iconTheme: const IconThemeData(size: 16.0, color: Colors.white),
            elevatedButtonTheme: const ElevatedButtonThemeData(
                style: ButtonStyle(minimumSize: MaterialStatePropertyAll(Size(110, 40))))),
        home: AlertMessenger(child: Builder(builder: (context) {
          String textAlert = setTextAlert(AlertMessenger.of(context).typeAlertPriority);
          return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                title: const Text('Alerts'),
                centerTitle: true,
              ),
              body: SafeArea(
                  child: Column(children: [
                Expanded(
                    flex: 3,
                    child: Center(child: Text(textAlert, style: TextStyle(color: Colors.grey[500], fontSize: 16.0)))),
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                ElevatedButton(
                                    onPressed: () {
                                      AlertMessenger.of(context).showAlert(
                                          alert: Alert(
                                              backgroundColor: Colors.red,
                                              leading: const Icon(Icons.error),
                                              priority: AlertPriority.error,
                                              child: Text(textErrorAlert)));
                                    },
                                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                                    child: const Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.error),
                                          SizedBox(width: 4.0),
                                          Text('Error'),
                                        ])),
                                ElevatedButton(
                                    onPressed: () {
                                      AlertMessenger.of(context).showAlert(
                                          alert: Alert(
                                              backgroundColor: Colors.amber,
                                              leading: const Icon(Icons.warning),
                                              priority: AlertPriority.warning,
                                              child: Text(textWarningAlert)));
                                    },
                                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.amber)),
                                    child: const Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.warning_outlined),
                                          SizedBox(width: 4.0),
                                          Text('Warning'),
                                        ])),
                                ElevatedButton(
                                    onPressed: () {
                                      AlertMessenger.of(context).showAlert(
                                          alert: Alert(
                                              backgroundColor: Colors.green,
                                              leading: const Icon(Icons.info),
                                              priority: AlertPriority.info,
                                              child: Text(textInfoAlert)));
                                    },
                                    style:
                                        const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.lightGreen)),
                                    child: const Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.info_outline),
                                          SizedBox(width: 4.0),
                                          Text('Info'),
                                        ]))
                              ]),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  child: ElevatedButton(
                                    onPressed: AlertMessenger.of(context).hideAlert,
                                    child: const Text('Hide alert'),
                                  ))
                            ])))
              ])));
        })));
  }
}
