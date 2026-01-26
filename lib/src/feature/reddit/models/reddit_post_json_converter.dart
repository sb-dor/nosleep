import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

final class RedditPostJsonConverter extends JsonConverter<RedditPost, Map<String, Object?>> {
  @override
  RedditPost fromJson(final Map<String, Object?> json) =>
      RedditPost(id: json['id'] as String, title: json['title'] as String);

  @override
  Map<String, Object?> toJson(final RedditPost object) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
