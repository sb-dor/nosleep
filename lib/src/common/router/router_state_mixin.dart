import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier;
import 'package:no_sleep/src/common/router/routes.dart';
import 'package:octopus/octopus.dart';

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final Octopus router;
  late final ValueNotifier<List<({Object error, StackTrace stackTrace})>> errorsObserver;

  @override
  void initState() {
    errorsObserver = ValueNotifier<List<({Object error, StackTrace stackTrace})>>(
      <({Object error, StackTrace stackTrace})>[],
    );

    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.initialization, // change defaultRoute if it's not needed
      onError: (error, stackTrace) =>
          errorsObserver.value = <({Object error, StackTrace stackTrace})>[
            (error: error, stackTrace: stackTrace),
            ...errorsObserver.value,
          ],
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }
}
