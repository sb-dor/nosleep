import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/article/controller/article_controller.dart';
import 'package:no_sleep/src/feature/article/models/article.dart';
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_comment.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';

/// MOBILE VERSION
/// Логика полностью такая же как на desktop:
/// CustomScrollView → Post → Divider → Comments
/// Только:
///  - меньшие отступы
///  - меньше шрифты
///  - глубина комментариев компактнее

class ArticleMobileWidget extends StatefulWidget {
  const ArticleMobileWidget({super.key});

  @override
  State<ArticleMobileWidget> createState() => _ArticleMobileWidgetState();
}

class _ArticleMobileWidgetState extends State<ArticleMobileWidget> {
  late final _config = ArticleConfigInhWidget.of(context);
  late final _controller = _config.articleController;
  late final _postId = _config.postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, title: const Text('NoSleep')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (_, _) {
            final state = _controller.state;

            return switch (state) {
              Article$InitialState() ||
              Article$InProgressState() => const Center(child: CircularProgressIndicator()),

              Article$ErrorState() => const Center(
                child: Text('Failed to load article', style: TextStyle(color: Colors.redAccent)),
              ),

              Article$CompletedState(:final article) => _ArticleMobileScroll(article: article!),
            };
          },
        ),
      ),
    );
  }
}

/// ======================
/// SCROLL
/// ======================

class _ArticleMobileScroll extends StatelessWidget {
  const _ArticleMobileScroll({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final flatComments = _flatten(article.comments);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          sliver: SliverToBoxAdapter(child: _PostHeader(post: article.post)),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _PostBody(post: article.post)),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverToBoxAdapter(child: _PostStats(post: article.post)),
        ),

        const SliverToBoxAdapter(child: Divider(height: 1)),

        if (flatComments.isNotEmpty)
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

        if (flatComments.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final comment = flatComments[index];
                return _CommentTile(comment: comment);
              }, childCount: flatComments.length),
            ),
          ),
      ],
    );
  }
}

/// ======================
/// POST PARTS
/// ======================

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'u/${post.author ?? "anonymous"}',
              style: const TextStyle(color: Colors.orange, fontSize: 13),
            ),
            const SizedBox(width: 8),
            if (post.subreddit != null)
              Text('r/${post.subreddit}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    if (post.selftext == null || post.selftext!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SelectableText(post.selftext!, style: const TextStyle(fontSize: 14, height: 1.5));
  }
}

class _PostStats extends StatelessWidget {
  const _PostStats({required this.post});

  final RedditPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(Icons.arrow_upward, post.ups),
        _stat(Icons.arrow_downward, post.downs),
        _stat(Icons.chat_bubble_outline, post.numComments),
      ],
    );
  }

  Widget _stat(IconData icon, int? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text('${value ?? 0}', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

/// ======================
/// COMMENTS
/// ======================

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: comment.depth * 12, // меньше чем на desktop
        top: 6,
        bottom: 6,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: comment.isStickied
                ? Colors.green
                : comment.isLocked
                ? Colors.red
                : Colors.grey.shade800,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  comment.author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${comment.score}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (comment.isStickied) ...[
                  const SizedBox(width: 6),
                  const Text('STICKIED', style: TextStyle(fontSize: 10, color: Colors.green)),
                ],
                if (comment.isLocked) ...[
                  const SizedBox(width: 6),
                  const Text('LOCKED', style: TextStyle(fontSize: 10, color: Colors.red)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.body, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

/// ======================
/// FLATTENER
/// ======================

List<RedditComment> _flatten(List<RedditComment> source) {
  final result = <RedditComment>[];

  void walk(List<RedditComment> list) {
    for (final c in list) {
      result.add(c);
      if (c.replies.isNotEmpty) {
        walk(c.replies);
      }
    }
  }

  walk(source);
  return result;
}
