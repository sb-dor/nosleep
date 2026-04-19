// ignore_for_file: avoid_positional_boolean_parameters
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> $captureException(Object exception, StackTrace stackTrace, String? hint, bool fatal) {
  if (kReleaseMode && defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return FirebaseCrashlytics.instance.recordError(exception, stackTrace, fatal: true);
  }
  // use other service for macos/linux/windows (sentry)
  return Future.value();
}

Future<void> $captureMessage(String message, StackTrace? stackTrace, String? hint, bool warning) =>
    Future<void>.value();
