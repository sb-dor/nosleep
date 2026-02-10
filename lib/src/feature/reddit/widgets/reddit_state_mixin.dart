import 'dart:async';

import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

mixin RedditStateMixin<T extends StatefulWidget> on State<T> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;
  late final scrollController = _redditInhWidget.scrollController;
  late final searchController = _redditInhWidget.searchController;

  Timer? _searchTimer;
  String? _lastSearch;

  String? get _currentSearchControllerValue =>
      searchController.text.trim().length < 3 ? null : searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _lastSearch = _currentSearchControllerValue;
    scrollController.addListener(_listener);
    searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    searchController.removeListener(_onSearchChange);
    super.dispose();
  }

  void load({final bool reload = false}) {
    redditController.load(
      redditDataController.subreddit,
      postType: redditDataController.postType,
      reload: reload,
    );
    _lastSearch = _currentSearchControllerValue;
  }

  void _listener() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      redditController.paginate(
        redditDataController.subreddit,
        postType: redditDataController.postType,
      );
    }
  }

  void _onSearchChange() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 1), () {
      if (_lastSearch == _currentSearchControllerValue) return;
      final textLessThenLength = searchController.text.trim().length < 3;
      if (textLessThenLength) {
        /// load default [nosleep] search
        redditDataController.setSubreddit(noSleep);
        load(reload: true);
        return;
      }
      if (textLessThenLength) return;
      redditDataController.setSubreddit(searchController.text.trim());
      load(reload: true);
    });
  }
}
