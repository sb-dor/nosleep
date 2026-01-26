import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_json_converter.dart';

abstract interface class IRedditRepository {
  Future<List<RedditPost>> getPosts(String subreddit, {int limit = 10});

  Future<List<RedditPost>> getComments(String subreddit, String postId, {int limit = 10});
}

final class RedditRepositoryImpl implements IRedditRepository {
  RedditRepositoryImpl({final http.Client? httpClient}) : httpClient = httpClient ?? http.Client();

  final http.Client httpClient;

  @override
  Future<List<RedditPost>> getPosts(String subreddit, {int limit = 10}) async {
    final uri = Uri.parse('https://www.reddit.com/r/$subreddit/new.json?limit=$limit');

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, Object?>;
      final jsonConverter = RedditPostJsonConverter();

      // Parse the Reddit API response structure
      // The structure is: {data: {children: [{data: {...}}, {data: {...}}]}}
      final dataList = jsonData['data'] as Map<String, Object?>?;
      final childrenList = dataList?['children'] as List<Object?>?;

      if (childrenList != null) {
        final posts = <RedditPost>[];
        for (final child in childrenList) {
          final childMap = child as Map<String, Object?>?;
          final postData = childMap?['data'] as Map<String, Object?>?;
          print('child list: $postData');

          if (postData != null) {
            final post = jsonConverter.fromJson(postData);
            posts.add(post);
          }
        }
        return posts;
      }
      return [];
    }
    throw Exception('Failed to load posts: ${response.statusCode}');
  }

  @override
  Future<List<RedditPost>> getComments(String subreddit, String postId, {int limit = 10}) async {
    final uri = Uri.parse('https://www.reddit.com/r/$subreddit/comments/$postId/new.json');

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final jsonConverter = RedditPostJsonConverter();

      // For comments, the structure might be different
      // It's typically an array with the first element being post info and second being comments
      if (jsonData is List && jsonData.length > 1) {
        // Second element in the list typically contains the comments
        final commentsData = jsonData[1] as Map<String, Object?>?;
        final dataList = commentsData?['data'] as Map<String, Object?>?;
        final childrenList = dataList?['children'] as List<Object?>?;

        if (childrenList != null) {
          final comments = <RedditPost>[];
          for (final child in childrenList) {
            final childMap = child as Map<String, Object?>?;
            final commentData = childMap?['data'] as Map<String, Object?>?;

            if (commentData != null) {
              try {
                final comment = jsonConverter.fromJson(commentData);
                comments.add(comment);
              } catch (e) {
                // Skip items that fail to parse
                continue;
              }
            }
          }
          return comments;
        }
      } else {
        // Alternative structure - might be direct data.children
        final dataList = jsonData['data'] as Map<String, Object?>?;
        final childrenList = dataList?['children'] as List<Object?>?;

        if (childrenList != null) {
          final comments = <RedditPost>[];
          for (final child in childrenList) {
            final childMap = child as Map<String, Object?>?;
            final commentData = childMap?['data'] as Map<String, Object?>?;

            if (commentData != null) {
              try {
                final comment = jsonConverter.fromJson(commentData);
                comments.add(comment);
              } catch (e) {
                // Skip items that fail to parse
                continue;
              }
            }
          }
          return comments;
        }
      }

      return [];
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }
}
