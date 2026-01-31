import 'package:flutter/material.dart';

class NotificationsConfigWidget extends StatefulWidget {
  const NotificationsConfigWidget({super.key});

  @override
  State<NotificationsConfigWidget> createState() => _NotificationsConfigWidgetState();
}

class _NotificationsConfigWidgetState extends State<NotificationsConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Empty notifications')),
    );
  }
}
