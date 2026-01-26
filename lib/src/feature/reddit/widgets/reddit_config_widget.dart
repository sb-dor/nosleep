import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/util/screen_util.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/data/reddit_repository.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/desktop/reddit_desktop_widget.dart';
import 'package:no_sleep/src/feature/reddit/widgets/mobile/reddit_mobile_widget.dart';
import 'package:no_sleep/src/feature/reddit/widgets/tablet/reddit_tablet_widget.dart';

/// Inherited widgets that provides access to RedditConfigWidgetState throughout the widgets tree.
class RedditConfigInhWidget extends InheritedWidget {
  const RedditConfigInhWidget({required this.state, required super.child, super.key});

  static RedditConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<RedditConfigInhWidget>()?.widget;
    assert(widget != null, 'RedditConfigInhWidget was not found in element tree');
    return (widget as RedditConfigInhWidget).state;
  }

  final RedditConfigWidgetState state;

  @override
  bool updateShouldNotify(RedditConfigInhWidget old) => false;
}

class RedditConfigWidget extends StatefulWidget {
  const RedditConfigWidget({super.key});

  @override
  State<RedditConfigWidget> createState() => RedditConfigWidgetState();
}

class RedditConfigWidgetState extends State<RedditConfigWidget> {
  late final RedditController redditController;
  late final RedditDataController redditDataController;

  @override
  void initState() {
    super.initState();
    redditController = RedditController(redditRepository: RedditRepositoryImpl());
  }

  @override
  void dispose() {
    redditController.dispose();
    redditDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RedditConfigInhWidget(
    state: this,
    child: context.screenSizeMaybeWhen(
      orElse: () => const RedditDesktopWidget(),
      phone: () => const RedditMobileWidget(),
      tablet: () => const RedditTabletWidget(),
    ),
  );
}
