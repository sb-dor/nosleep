import 'package:flutter/foundation.dart';

@immutable
class RedditComment {
  const RedditComment({
    required this.id,
    required this.author,
    required this.body,
    required this.permalink,
    required this.score,
    required this.createdUtc,
    this.replies = const [],
    this.isStickied = false,
    this.isLocked = false,
    this.depth = 0,
  });

  final String id;
  final String author;
  final String body;
  final String permalink;
  final int score;
  final DateTime createdUtc;
  final List<RedditComment> replies;
  final bool isStickied;
  final bool isLocked;
  final int depth;
}
