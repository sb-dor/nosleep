import 'package:no_sleep/src/common/util/api_client.dart';
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
  RedditRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  /// AI generated code - should be rewritten
  @override
  Future<({List<RedditPost> posts, String? nextPage})> getPosts(
    final String subreddit, {
    final int limit = 10,
    final RedditPostType postType = RedditPostType.newest,
    final String? nextPage,
  }) async {
    final response = await apiClient.get(
      '/r/$subreddit/${postType.key}.json',
      queryParameters: <String, String?>{'limit': limit.toString(), 'after': nextPage},
    );

    if (response.statusCode == 200) {
      final jsonConverter = RedditPostJsonConverter();

      // Parse the Reddit API response structure
      // The structure is: {data: {children: [{data: {...}}, {data: {...}}]}}
      final dataList = response.body['data'] as Map<String, Object?>?;
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

final class RedditJSRepositoryImpl implements IRedditRepository {
  RedditJSRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  /// AI generated code - should be rewritten
  @override
  Future<({List<RedditPost> posts, String? nextPage})> getPosts(
    final String subreddit, {
    final int limit = 10,
    final RedditPostType postType = RedditPostType.newest,
    final String? nextPage,
  }) async {
    final response = await apiClient.get(
      '/posts',
      queryParameters: <String, String?>{
        'subreddit': subreddit.trim(),
        'limit': limit.toString(),
        'type': postType.key,
        'after': nextPage,
      },
    );

    if (response.statusCode == 200) {
      final jsonConverter = RedditPostJsonConverter();

      // Parse the Reddit API response structure
      // The structure is: {data: {children: [{data: {...}}, {data: {...}}]}}
      final dataList = response.body['data'] as Map<String, Object?>?;
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
