import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';

const String noSleep = 'nosleep';

const String noSleepTitle = 'NoSleep';

class RedditDataController with ChangeNotifier {
  /// default subreddit
  String _subreddit = noSleep;

  RedditPostType _postType = RedditPostType.newest;

  Widget? _desktopSelectedArticle;

  String get subreddit => _subreddit;

  RedditPostType get postType => _postType;

  Widget? get desktopSelectedArticle => _desktopSelectedArticle;

  void setSubreddit(String subreddit) {
    _subreddit = subreddit;
    notifyListeners();
  }

  void setPostType(final RedditPostType postType) {
    _postType = postType;
    notifyListeners();
  }

  void setDesktopArticle(final Widget article) {
    _desktopSelectedArticle = article;
    notifyListeners();
  }
}
