import 'dart:async';

import 'package:control/control.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:l/l.dart';
import 'package:no_sleep/firebase_options.dart';
import 'package:no_sleep/src/common/constant/config.dart';
import 'package:no_sleep/src/common/constant/pubspec.yaml.g.dart';
import 'package:no_sleep/src/common/controller/controller_observer.dart';
import 'package:no_sleep/src/common/model/app_metadata.dart';
import 'package:no_sleep/src/common/util/api_client.dart';
import 'package:no_sleep/src/common/util/middleware/logger_mw.dart';
import 'package:no_sleep/src/common/util/screen_util.dart';
import 'package:no_sleep/src/feature/initialization/data/platform/platform_initialization.dart';
import 'package:no_sleep/src/feature/initialization/models/dependencies.dart';
import 'package:platform_info/platform_info.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      l.v6('Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"');
      await step.value(dependencies);
    } on Object catch (error, stackTrace) {
      l.e('Initialization failed at step "${step.key}": $error', stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.key}": $error', stackTrace);
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(Dependencies dependencies);

final Map<String, _InitializationStep> _initializationSteps = <String, _InitializationStep>{
  'Initializing Firebase': (_) =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  'Platform pre-initialization': (_) => $platformInitialization(),
  'Creating app metadata': (dependencies) => dependencies.metadata = AppMetadata(
    isWeb: platform.js,
    isRelease: platform.buildMode.release,
    appName: Pubspec.name,
    appVersion: Pubspec.version.representation,
    appVersionMajor: Pubspec.version.major,
    appVersionMinor: Pubspec.version.minor,
    appVersionPatch: Pubspec.version.patch,
    appBuildTimestamp: Pubspec.version.build.isNotEmpty
        ? (int.tryParse(Pubspec.version.build.firstOrNull ?? '-1') ?? -1)
        : -1,
    operatingSystem: platform.operatingSystem.name,
    processorsCount: platform.numberOfProcessors,
    appLaunchedTimestamp: DateTime.now(),
    locale: platform.locale,
    deviceVersion: platform.version,
    deviceScreenSize: ScreenUtil.screenSize().representation,
  ),
  'Observer state management': (_) => Controller.observer = const ControllerObserver(),
  'Initializing analytics': (_) {},
  'Log app open': (_) {},
  'Get remote config': (_) {},
  'Restore settings': (_) {},
  'API Client': (dependencies) => dependencies.apiClient = ApiClient(
    baseUrl: Config.apiBaseUrl,
    middlewares: [
      //
      const ApiClient$LoggerMiddleware(logRequest: false, logResponse: true, logError: true).call,
      // dedupe interceptor
      // authentification interceptor
      // save all requests to database
      // sentry interceptor
      // cache interceptor
      // retry interceptor
    ],
  ),

  // The 'Shrink database' step will only be included in non-release builds.
};
