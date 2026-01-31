import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/developer/widget/developer_screen.dart';
import 'package:no_sleep/src/feature/home/widgets/home_widget.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  initialization('initialization'),
  nosleep('nosleep', title: 'Sign-In'),
  developer('developer');

  const Routes(this.name, {this.title});

  @override
  final String name;

  /// title is not necessary
  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    Routes.initialization => const HomeWidget(),
    Routes.developer => const DeveloperScreen(),
    Routes.nosleep => const RedditConfigWidget(),
    // Routes.signup => const SignUpScreen(),
    // Routes.home => const HomeScreen(),
    // Routes.profile => const ProfileScreen(),
    // Routes.developer => const DeveloperScreen(),
    // Routes.settings => const SettingsScreen(),
  };
}
