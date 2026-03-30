import 'package:flutter/widgets.dart';
import 'package:no_sleep/src/common/model/app_metadata.dart';
import 'package:no_sleep/src/common/util/api_client.dart';
import 'package:no_sleep/src/feature/initialization/widget/dependencies_scope.dart';

/// {@template dependencies}
/// Application dependencies.
/// {@endtemplate}
class Dependencies {
  /// {@macro dependencies}
  Dependencies();

  /// The state from the closest instance of this class.
  ///
  /// {@macro dependencies}
  factory Dependencies.of(BuildContext context) => DependenciesScope.of(context);

  /// Injest dependencies to the widget tree.
  Widget inject({required Widget child, Key? key}) =>
      DependenciesScope(dependencies: this, key: key, child: child);

  /// App metadata
  late final AppMetadata metadata;

  /// API Client
  late final ApiClient apiClient;

  @override
  String toString() => 'Dependencies{}';
}

/// Fake Dependencies
@visibleForTesting
class FakeDependencies extends Dependencies {
  FakeDependencies();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // ... implement fake dependencies
    throw UnimplementedError();
  }
}
