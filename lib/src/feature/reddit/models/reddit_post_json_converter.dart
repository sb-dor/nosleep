import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

final class RedditPostJsonConverter extends JsonConverter<RedditPost, Map<String, Object?>> {
  @override
  RedditPost fromJson(final Map<String, Object?> json) => RedditPost(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        // author: json['author'] as String?,
        // selftext: json['selftext'] as String?,
        // url: json['url'] as String?,
        // permalink: json['permalink'] as String?,
        // score: json['score'] as int?,
        // ups: json['ups'] as int?,
        // downs: json['downs'] as int?,
        // numComments: json['num_comments'] as int?,
        // thumbnail: json['thumbnail'] as String?,
        // imageUrl: json['url'] as String?, // Use 'url' for image if available
        // created: json['created'] != null ? DateTime.fromMillisecondsSinceEpoch((json['created'] as num).toInt() * 1000) : null,
        // createdUtc: json['created_utc'] != null ? DateTime.fromMillisecondsSinceEpoch((json['created_utc'] as num).toInt() * 1000) : null,
        // over18: json['over_18'] as bool?,
        // spoiler: json['spoiler'] as bool?,
        // nsfw: json['over_18'] as bool?, // NSFW is often the same as over_18
        // subreddit: json['subreddit'] as String?,
        // subredditType: json['subreddit_type'] as String?,
        // subredditSubscribers: json['subreddit_subscribers'] as String?,
        // media: json['media'] as Map<String, Object?>?,
      );

  @override
  Map<String, Object?> toJson(final RedditPost object) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
