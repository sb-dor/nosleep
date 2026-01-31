import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.octopus.setState(
        (stack) => stack
          ..clear()
          ..add(Routes.nosleep.node()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
  }
}
