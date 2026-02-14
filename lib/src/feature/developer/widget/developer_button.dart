import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/localization/localization.dart';
import 'package:no_sleep/src/feature/developer/widget/developer_screen.dart';

/// {@template developer_button}
/// DeveloperButton widget
/// {@endtemplate}
class DeveloperButton extends StatelessWidget {
  /// {@macro developer_button}
  const DeveloperButton({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    backgroundColor: Colors.black,
    tooltip: Localization.of(context).developer,
    onPressed: () => showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => const DeveloperScreen(),
    ),
    child: const Icon(Icons.developer_mode, color: Colors.red),
  );
}
