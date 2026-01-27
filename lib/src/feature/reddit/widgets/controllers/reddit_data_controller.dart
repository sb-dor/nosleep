import 'package:flutter/foundation.dart';

class RedditDataController with ChangeNotifier {
  String? _selectedSubreddit;

  String? get selectedSubreddit => _selectedSubreddit;

  void setSelectedSubreddit(String? subreddit) {
    _selectedSubreddit = subreddit;
    notifyListeners();
  }

  String? _currentPostId;

  String? get currentPostId => _currentPostId;

  void setCurrentPostId(String? postId) {
    _currentPostId = postId;
    notifyListeners();
  }
}
