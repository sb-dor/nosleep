import 'package:flutter/foundation.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_comment.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

@immutable
class Article {
  const Article({required this.post, required this.comments});

  final RedditPost post;
  final List<RedditComment> comments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article &&
          runtimeType == other.runtimeType &&
          post == other.post &&
          comments == other.comments;

  @override
  int get hashCode => Object.hash(post, comments);
}
