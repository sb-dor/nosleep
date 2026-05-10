import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:l/l.dart';
import 'package:no_sleep/src/common/constant/pubspec.yaml.g.dart';
import 'package:no_sleep/src/common/util/platform/availability/platform_availability.dart';
import 'package:no_sleep/src/common/util/url_launcher_helper.dart';
import 'package:no_sleep/src/feature/in_app_update/widgets/in_app_update_bottom_sheet.dart';

class InAppUpdateHostWidget extends StatefulWidget {
  const InAppUpdateHostWidget({
    super.key,
    required this.builder,
    this.checkForUpdate = kReleaseMode,
  });

  final WidgetBuilder builder;
  final bool checkForUpdate;

  @override
  State<InAppUpdateHostWidget> createState() => _InAppUpdateHostWidgetState();
}

class _InAppUpdateHostWidgetState extends State<InAppUpdateHostWidget> with WidgetsBindingObserver {
  var _isChecking = false;
  var _isUpdating = false;
  var _updateAvailable = false;
  var _sheetShown = false;
  var _sheetScheduled = false;

  @override
  void initState() {
    super.initState();
    if (kInAppUpdatePlatform && widget.checkForUpdate) {
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkForUpdate();
      });
    }
  }

  @override
  void dispose() {
    if (kInAppUpdatePlatform && widget.checkForUpdate) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _sheetShown) return;

    _checkForUpdate();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  Future<void> _checkForUpdate() async {
    if (!mounted || _isChecking || _isUpdating || _updateAvailable) return;

    _isChecking = true;
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      l.d('In-app update check result: ${_formatUpdateInfo(updateInfo)}');
      if (!mounted) return;

      if (updateInfo.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        await _startUpdate();
        return;
      }

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        _updateAvailable = true;
        _scheduleUpdateSheet();
      }
    } on Object catch (error) {
      l.d('In-app update check error: $error');
      _showSnackBar(error.toString());
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _startUpdate() async {
    if (_isUpdating) return;

    _isUpdating = true;
    try {
      // Current flow: immediate update. Google Play owns the visible update UI
      // after the user accepts our custom bottom sheet.
      final result = await InAppUpdate.performImmediateUpdate();
      l.d('In-app immediate update result: $result');
      if (result == AppUpdateResult.userDeniedUpdate) {
        _showSnackBar('Update canceled.');
      } else if (result == AppUpdateResult.inAppUpdateFailed) {
        _showSnackBar('Update failed.');
      }
    } on Object catch (error) {
      l.d('In-app update start error: $error');
      _showSnackBar(error.toString());
    } finally {
      _isUpdating = false;
      _updateAvailable = false;
    }
  }

  void _scheduleUpdateSheet() {
    if (_sheetScheduled || _sheetShown) return;

    _sheetScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetScheduled = false;
      if (!mounted || _sheetShown) return;

      if (Navigator.maybeOf(context) == null) return;

      _sheetShown = true;
      _showUpdateSheet();
    });
  }

  Future<void> _showUpdateSheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: const Color(0xFF171717),
      barrierColor: Colors.black.withValues(alpha: 0.55),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => InAppUpdateBottomSheet(
        onLearnMore: () => _openGooglePlay(context),
        onUpdate: () {
          Navigator.of(context).maybePop();
          _startUpdate();
        },
      ),
    );
  }

  Future<void> _openGooglePlay(BuildContext context) async {
    final googlePlayUrl = Pubspec.source['google_play'] as String?;
    if (googlePlayUrl == null || googlePlayUrl.isEmpty) return;

    Navigator.of(context).maybePop();
    if (!mounted) return;
    await UrlLauncherHelper().openUrl(googlePlayUrl);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatUpdateInfo(AppUpdateInfo updateInfo) {
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

  /*
   * Previous flexible-update flow kept here as a reference.
   *
   * Main differences:
   * - The availability check used `updateInfo.flexibleUpdateAllowed`.
   * - `_startUpdate` called `InAppUpdate.startFlexibleUpdate()`.
   * - The app listened to `InAppUpdate.installUpdateListener`.
   * - When `InstallStatus.downloaded` arrived, the app called
   *   `InAppUpdate.completeFlexibleUpdate()`.
   * - This package exposes install statuses only; it does not expose a real
   *   download percentage.
   *
   * Example:
   *
   * StreamSubscription<InstallStatus>? _installSubscription;
   *
   * if (updateInfo.installStatus == InstallStatus.downloaded) {
   *   await InAppUpdate.completeFlexibleUpdate();
   *   _showSnackBar('Update downloaded. Restarting app update flow.');
   *   return;
   * }
   *
   * if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
   *     updateInfo.flexibleUpdateAllowed) {
   *   _updateAvailable = true;
   *   _scheduleUpdateSheet();
   * }
   *
   * Future<void> _startFlexibleUpdate() async {
   *   if (_isUpdating) return;
   *
   *   _isUpdating = true;
   *   _listenForFlexibleUpdateCompletion();
   *   try {
   *     await InAppUpdate.startFlexibleUpdate();
   *     l.d('In-app flexible update started.');
   *   } on Object catch (error) {
   *     await _installSubscription?.cancel();
   *     _installSubscription = null;
   *     _isUpdating = false;
   *     l.d('In-app flexible update start error: $error');
   *     _showSnackBar(error.toString());
   *   }
   * }
   *
   * void _listenForFlexibleUpdateCompletion() {
   *   _installSubscription?.cancel();
   *   _installSubscription = InAppUpdate.installUpdateListener.listen(
   *     (status) async {
   *       l.d('In-app update install status: ${status.name}');
   *       switch (status) {
   *         case InstallStatus.downloaded:
   *           await _installSubscription?.cancel();
   *           _installSubscription = null;
   *           try {
   *             await InAppUpdate.completeFlexibleUpdate();
   *             _isUpdating = false;
   *             _showSnackBar('Update downloaded. Restarting app update flow.');
   *           } on Object catch (error) {
   *             _isUpdating = false;
   *             l.d('In-app flexible update complete error: $error');
   *             _showSnackBar(error.toString());
   *           }
   *         case InstallStatus.failed:
   *         case InstallStatus.canceled:
   *           await _installSubscription?.cancel();
   *           _installSubscription = null;
   *           _isUpdating = false;
   *           _showSnackBar('Update ${status.name}.');
   *         case InstallStatus.unknown:
   *         case InstallStatus.pending:
   *         case InstallStatus.downloading:
   *         case InstallStatus.installing:
   *         case InstallStatus.installed:
   *           break;
   *       }
   *     },
   *     onError: (Object error) {
   *       _isUpdating = false;
   *       l.d('In-app update install listener error: $error');
   *       _showSnackBar(error.toString());
   *     },
   *   );
   * }
   */
}
