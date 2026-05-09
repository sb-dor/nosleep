import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:no_sleep/src/feature/in_app_update/data/in_app_update_repository.dart';

part 'in_app_update_controller.freezed.dart';

@freezed
sealed class InAppUpdateState with _$InAppUpdateState {
  const factory InAppUpdateState.initial() = InAppUpdate$InitialState;

  const factory InAppUpdateState.checking() = InAppUpdate$CheckingState;

  const factory InAppUpdateState.notAvailable() = InAppUpdate$NotAvailableState;

  const factory InAppUpdateState.available(AppUpdateInfo updateInfo) = InAppUpdate$AvailableState;

  const factory InAppUpdateState.updating() = InAppUpdate$UpdatingState;

  const factory InAppUpdateState.completed() = InAppUpdate$CompletedState;

  const factory InAppUpdateState.error(String message) = InAppUpdate$ErrorState;
}

final class InAppUpdateController extends StateController<InAppUpdateState>
    with SequentialControllerHandler {
  InAppUpdateController({
    required final IInAppUpdateRepository inAppUpdateRepository,
    super.initialState = const InAppUpdateState.initial(),
  }) : _inAppUpdateRepository = inAppUpdateRepository;

  final IInAppUpdateRepository _inAppUpdateRepository;
  StreamSubscription<InstallStatus>? _installSubscription;

  static final ValueNotifier<String?> lastCheckDebugInfo = ValueNotifier<String?>(null);

  static Future<void> debugCheckForUpdate({
    IInAppUpdateRepository inAppUpdateRepository = const InAppUpdateRepositoryImpl(),
  }) async {
    try {
      final updateInfo = await inAppUpdateRepository.checkForUpdate();
      _setDebugInfo('manual check result: ${_formatUpdateInfo(updateInfo)}');
    } on Object catch (error) {
      _setDebugInfo('manual check error: $error');
    }
  }

  Future<void> checkForUpdate() => handle(
    () async {
      if (state is InAppUpdate$CheckingState ||
          state is InAppUpdate$AvailableState ||
          state is InAppUpdate$UpdatingState ||
          state is InAppUpdate$CompletedState) {
        return;
      }

      setState(const InAppUpdateState.checking());

      final updateInfo = await _inAppUpdateRepository.checkForUpdate();
      _setDebugInfo('check result: ${_formatUpdateInfo(updateInfo)}');
      if (updateInfo == null) {
        setState(const InAppUpdateState.notAvailable());
        return;
      }

      // A flexible update from a previous session is already on disk — install
      // it now instead of asking the user to start the flow over.
      if (updateInfo.installStatus == InstallStatus.downloaded) {
        await _inAppUpdateRepository.completeFlexibleUpdate();
        setState(const InAppUpdateState.completed());
        return;
      }

      // A flexible update is mid-download from a previous session — wait for it
      // to finish and then install.
      if (updateInfo.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        setState(const InAppUpdateState.updating());
        _listenForCompletion();
        return;
      }

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {
        setState(InAppUpdateState.available(updateInfo));
        return;
      }

      setState(const InAppUpdateState.notAvailable());
    },
    error: (error, stackTrace) async {
      _setDebugInfo('check error: $error');
      setState(InAppUpdateState.error(error.toString()));
    },
  );

  Future<void> startUpdate() => handle(
    () async {
      setState(const InAppUpdateState.updating());
      _listenForCompletion();
      // Returns once the user accepts the system dialog; the download then runs
      // in the background and is reported via [installStatusStream].
      await _inAppUpdateRepository.startFlexibleUpdate();
      _setDebugInfo('flexible update started.');
    },
    error: (error, stackTrace) async {
      await _installSubscription?.cancel();
      _installSubscription = null;
      _setDebugInfo('start error: $error');
      setState(InAppUpdateState.error(error.toString()));
    },
  );

  void _listenForCompletion() {
    _installSubscription?.cancel();
    _installSubscription = _inAppUpdateRepository.installStatusStream.listen(
      (status) async {
        _setDebugInfo('install status: ${status.name}');
        switch (status) {
          case InstallStatus.downloaded:
            await _installSubscription?.cancel();
            _installSubscription = null;
            try {
              await _inAppUpdateRepository.completeFlexibleUpdate();
              _setDebugInfo('complete flexible update requested.');
              setState(const InAppUpdateState.completed());
            } on Object catch (error) {
              _setDebugInfo('complete error: $error');
              setState(InAppUpdateState.error(error.toString()));
            }
          case InstallStatus.failed:
          case InstallStatus.canceled:
            await _installSubscription?.cancel();
            _installSubscription = null;
            setState(InAppUpdateState.error('Update ${status.name}.'));
          case InstallStatus.unknown:
          case InstallStatus.pending:
          case InstallStatus.downloading:
          case InstallStatus.installing:
          case InstallStatus.installed:
            break;
        }
      },
      onError: (Object error) {
        _setDebugInfo('install listener error: $error');
        setState(InAppUpdateState.error(error.toString()));
      },
    );
  }

  static void _setDebugInfo(String message) {
    final value = '${DateTime.now().toIso8601String()} | $message';
    lastCheckDebugInfo.value = value;
  }

  static String _formatUpdateInfo(AppUpdateInfo? updateInfo) {
    if (updateInfo == null) return 'null';

    return 'availability=${updateInfo.updateAvailability.name}, '
        'availableVersionCode=${updateInfo.availableVersionCode}, '
        'installStatus=${updateInfo.installStatus.name}, '
        'packageName=${updateInfo.packageName}, '
        'flexibleAllowed=${updateInfo.flexibleUpdateAllowed}, '
        'flexiblePreconditions=${updateInfo.flexibleAllowedPreconditions}, '
        'immediateAllowed=${updateInfo.immediateUpdateAllowed}, '
        'immediatePreconditions=${updateInfo.immediateAllowedPreconditions}, '
        'stalenessDays=${updateInfo.clientVersionStalenessDays}, '
        'priority=${updateInfo.updatePriority}';
  }

  @override
  void dispose() {
    _installSubscription?.cancel();
    _installSubscription = null;
    super.dispose();
  }
}
