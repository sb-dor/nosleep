import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/constant/pubspec.yaml.g.dart';
import 'package:no_sleep/src/common/util/platform/availability/platform_availability.dart';
import 'package:no_sleep/src/common/util/url_launcher_helper.dart';
import 'package:no_sleep/src/feature/in_app_update/controller/in_app_update_controller.dart';
import 'package:no_sleep/src/feature/in_app_update/data/in_app_update_repository.dart';
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

class _InAppUpdateHostWidgetState extends State<InAppUpdateHostWidget> {
  InAppUpdateController? _controller;
  var _sheetShown = false;

  @override
  void initState() {
    super.initState();
    if (kInAppUpdatePlatform && widget.checkForUpdate) {
      _controller = InAppUpdateController(inAppUpdateRepository: const InAppUpdateRepositoryImpl());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller?.checkForUpdate();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kInAppUpdatePlatform && widget.checkForUpdate) {
      return StateConsumer<InAppUpdateController, InAppUpdateState>(
        controller: _controller,
        listener: _onStateChanged,
        child: widget.builder(context),
        builder: (context, state, child) => child ?? const SizedBox.shrink(),
      );
    } else {
      return widget.builder(context);
    }
  }

  void _onStateChanged(
    BuildContext context,
    InAppUpdateController controller,
    InAppUpdateState previous,
    InAppUpdateState current,
  ) {
    if (current is InAppUpdate$AvailableState && !_sheetShown) {
      _sheetShown = true;
      _showUpdateSheet();
    }

    if (current is InAppUpdate$CompletedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update downloaded. Restarting app update flow.')),
      );
    }

    if (current is InAppUpdate$ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(current.message)));
    }
  }

  Future<void> _showUpdateSheet() async {
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
          _controller?.startUpdate();
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
}
