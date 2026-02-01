import 'package:flutter/material.dart';
import 'package:no_sleep/src/common/util/screen_util.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_state_mixin.dart';
import 'package:octopus/octopus.dart';

/// This classes are necessary to determine which route user wants to navigate
/// Through url scheme that he set in the browser
///

sealed class RedditRoutingHandler {
  RedditRoutingHandler({required this.redditStateMixin});

  final RedditStateMixin redditStateMixin;

  void navigateTo(BuildContext context, final String id) {
    context.octopus.setState((stack) {
      stack.arguments.clear();
      return stack
        ..arguments['topic'] = redditStateMixin.redditDataController.subreddit
        ..arguments['id'] = id;
    });
    if (context.screenSize.isDesktop) {
      redditStateMixin.redditDataController.setDesktopArticle(
        ArticleConfigWidget(postId: id, key: ValueKey(id)),
      );
    } else {
      showDialog(
        useSafeArea: false,
        context: context,
        builder: (context) => Material(
          child: ArticleConfigWidget(postId: id, key: ValueKey(id)),
        ),
      );
    }
  }
}

final class DesktopRedditRouting extends RedditRoutingHandler {
  DesktopRedditRouting({required super.redditStateMixin});

  /// This function determines which module user wants to navigate
  /// If he is not authenticated to redirect to the specific route,
  /// he will be redirected to [Routes.home] module (does not need any permission)
  /// Same function works differently on mobile and desktop
  void findModule(BuildContext context) {
    if (!context.mounted) return;
    final arguments = context.octopus.state.arguments;
    final id = arguments['id'];
    final topic = arguments['topic'];
    if (id != null && topic != null) {
      redditStateMixin.searchController.text = topic;
      redditStateMixin.redditDataController.setSubreddit(topic);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.popUntil(context, (stack) => stack.isFirst);
        redditStateMixin.redditDataController
          ..setSubreddit(topic)
          ..setDesktopArticle(ArticleConfigWidget(postId: id, key: ValueKey(id)));
      });
    } else {
      redditStateMixin.redditController.load(noSleep);
    }
  }
}

final class MobileRedditRouting extends RedditRoutingHandler {
  MobileRedditRouting({required super.redditStateMixin});

  bool _preventDoubleNavigation = false;

  /// This function determines which module user wants to navigate
  /// If he is not authenticated to redirect to the specific route,
  /// he will be redirected to [Routes.home] module (does not need any permission)
  /// Same function works differently on mobile and desktop
  void findModule(BuildContext context) {
    if (_preventDoubleNavigation) return;
    final arguments = context.octopus.state.arguments;
    final id = arguments['id'];
    final topic = arguments['topic'];
    if (topic != null && id != null) {
      _preventDoubleNavigation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        redditStateMixin.searchController.text = topic;
        redditStateMixin.redditDataController.setSubreddit(topic);

        Navigator.popUntil(context, (stack) => stack.isFirst);
        showDialog(
          context: context,
          builder: (context) => Material(
            child: ArticleConfigWidget(postId: id, key: ValueKey(id)),
          ),
        ).whenComplete(() => _preventDoubleNavigation = false);
      });
    } else {
      redditStateMixin.redditController.load(noSleep);
    }
  }
}
