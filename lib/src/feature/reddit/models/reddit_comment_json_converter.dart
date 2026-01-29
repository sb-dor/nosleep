import 'dart:convert';

import 'package:no_sleep/src/feature/reddit/models/reddit_comment.dart';

final class RedditCommentJsonConverter extends Converter<Map<String, Object?>, RedditComment> {
  @override
  RedditComment convert(final Map<String, Object?> json) {
    final repliesRaw = json['replies'];

    var replies = <RedditComment>[];
    if (repliesRaw is Map<String, Object?>) {
      final data = repliesRaw['data'] as Map<String, Object?>?;
      final children = data?['children'] as List<dynamic>?;

      if (children != null) {
        replies = children
            .where((e) => e['kind'] == 't1')
            .map((e) => convert((e['data'] as Map).cast<String, Object?>()))
            .toList();
      }
    }

    return RedditComment(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'unknown',
      body: json['body'] as String? ?? '',
      permalink: json['permalink'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      createdUtc: DateTime.fromMillisecondsSinceEpoch(
        ((json['created_utc'] as num?) ?? 0).toInt() * 1000,
      ),
      isStickied: json['stickied'] as bool? ?? false,
      isLocked: json['locked'] as bool? ?? false,
      depth: json['depth'] as int? ?? 0,
      replies: replies,
    );
  }
}
