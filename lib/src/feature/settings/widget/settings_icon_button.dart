import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/localization/localization.dart';

/// {@template profile_icon_button}
/// ProfileIconButton widget
/// {@endtemplate}
class SettingsIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.person),
    tooltip: Localization.of(context).profileButton,
    onPressed: () {},
  );
}
