import 'package:no_sleep/src/common/util/api_client.dart';
import 'package:no_sleep/src/feature/article/models/article.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_comment_json_converter.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_json_converter.dart';

abstract interface class IArticleRepository {
  Future<Article> article(final String postId);
}

final class ArticleRepositoryImpl implements IArticleRepository {
  ArticleRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  /// AI generated code - should be rewrote
  @override
  Future<Article> article(final String postId) async {
    final response = await apiClient.get('/comments/$postId.json');

    if (response.statusCode != 200) {
      throw Exception('Failed to load article: ${response.statusCode}');
    }

    final postConverter = RedditPostJsonConverter();
    final commentConverter = RedditCommentJsonConverter();

    final root = response.body as List<dynamic>;

    // 1) Пост
    final postListing = root[0] as Map<String, dynamic>;
    final postChildren = postListing['data']['children'] as List<dynamic>;
    final postData = postChildren.first['data'] as Map<String, Object?>;

    final post = postConverter.fromJson(postData);

    // 2) Комментарии
    final commentsListing = root[1] as Map<String, dynamic>;
    final commentsChildren = commentsListing['data']['children'] as List<dynamic>;

    final comments = commentsChildren
        .where((e) => e['kind'] == 't1')
        .map((e) => commentConverter.convert((e['data'] as Map).cast<String, Object?>()))
        .toList();

    return Article(post: post, comments: comments);
  }
}

final class ArticleJSRepositoryImpl implements IArticleRepository {
  ArticleJSRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  /// AI generated code - should be rewrote
  @override
  Future<Article> article(final String postId) async {
    final response = await apiClient.get(
      '/comments',
      queryParameters: <String, String?>{'postId': postId},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load article: ${response.statusCode}');
    }

    final postConverter = RedditPostJsonConverter();
    final commentConverter = RedditCommentJsonConverter();

    // 1) Пост
    final data = response.body['data'] as Map<String, Object?>;
    final postChildren = data['children'] as List<dynamic>;
    final postData = postChildren.first['data'] as Map<String, Object?>;

    final post = postConverter.fromJson(postData);

    // 2) Комментарии
    final commentsChildren = data['children'] as List<dynamic>;

    final comments = commentsChildren
        .where((e) => e['kind'] == 't1')
        .map((e) => commentConverter.convert((e['data'] as Map).cast<String, Object?>()))
        .toList();

    return Article(post: post, comments: comments);
  }
}
