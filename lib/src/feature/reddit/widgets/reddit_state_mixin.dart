import 'dart:async';

import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

mixin RedditStateMixin<T extends StatefulWidget> on State<T> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;
  late final scrollController = ScrollController();
  late final searchController = TextEditingController();
  Timer? _searchTimer;
  bool _searchEmpty = true;
  String? _lastSearch;

  String? get _currentSearchControllerValue =>
      searchController.text.trim().length < 3 ? null : searchController.text.trim();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_listener);
    searchController.addListener(_onSearchChange);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_listener)
      ..dispose();
    searchController
      ..removeListener(_onSearchChange)
      ..dispose();
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
      if (_lastSearch == searchController.text.trim()) return;
      final textLessThenLength = searchController.text.trim().length < 3;
      if (!_searchEmpty && textLessThenLength) {
        /// load default [nosleep] search
        redditDataController.setSubreddit(noSleep);
        load();
        _searchEmpty = true;
        return;
      }
      if (textLessThenLength) return;
      _searchEmpty = false;
      redditDataController.setSubreddit(searchController.text.trim());
      load();
    });
  }
}
