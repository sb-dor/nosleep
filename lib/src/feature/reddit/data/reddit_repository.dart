import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_json_converter.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';

abstract interface class IRedditRepository {
  Future<({List<RedditPost> posts, String? nextPage})> getPosts(
    final String subreddit, {
    final int limit = 10,
    final RedditPostType postType = RedditPostType.newest,
    final String? nextPage,
  });
}

final class RedditRepositoryImpl implements IRedditRepository {
  RedditRepositoryImpl({final http.Client? httpClient}) : httpClient = httpClient ?? http.Client();

  final http.Client httpClient;

  /// AI generated code - should be rewrote
  @override
  Future<({List<RedditPost> posts, String? nextPage})> getPosts(
    final String subreddit, {
    final int limit = 10,
    final RedditPostType postType = RedditPostType.newest,
    final String? nextPage,
  }) async {
    final uri = Uri.parse(
      'https://api.reddit.com/r/$subreddit/${postType.key}.json?limit=$limit&after=$nextPage',
    );

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, Object?>;
      final jsonConverter = RedditPostJsonConverter();

      // Parse the Reddit API response structure
      // The structure is: {data: {children: [{data: {...}}, {data: {...}}]}}
      final dataList = jsonData['data'] as Map<String, Object?>?;
      final childrenList = dataList?['children'] as List<Object?>?;

      final nextPage = dataList?['after'] as String?;

      if (childrenList != null) {
        final posts = <RedditPost>[];
        for (final child in childrenList) {
          final childMap = child as Map<String, Object?>?;
          final postData = childMap?['data'] as Map<String, Object?>?;
          if (postData != null) {
            final post = jsonConverter.fromJson(postData);
            posts.add(post);
          }
        }
        return (posts: posts, nextPage: nextPage);
      }
    }
    throw Exception('Failed to load posts: ${response.body}');
  }
}
