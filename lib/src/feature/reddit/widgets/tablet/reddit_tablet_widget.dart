import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/common/widget/empty_widget.dart';
import 'package:no_sleep/src/common/widget/error_widget.dart' as error_widget;
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/notifications/widgets/notifications_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_state_mixin.dart';

class RedditTabletWidget extends StatefulWidget {
  const RedditTabletWidget({super.key});

  @override
  State<RedditTabletWidget> createState() => _RedditTabletWidgetState();
}

class _RedditTabletWidgetState extends State<RedditTabletWidget> with RedditStateMixin {
  @override
  Widget build(BuildContext context) => StateConsumer<RedditController, RedditState>(
    controller: redditController,
    builder: (context, state, child) {
      return ListenableBuilder(
        listenable: redditDataController,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: Row(
                children: [
                  const Icon(FontAwesomeIcons.skull, color: Color(0xFFd41132), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    redditDataController.subreddit,
                    style: const TextStyle(
                      color: Color(0xFFd41132),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsConfigWidget()),
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: ListenableBuilder(
                listenable: redditDataController,
                builder: (context, child) {
                  return RefreshIndicator.adaptive(
                    onRefresh: () async {
                      await redditController.load(
                        redditDataController.subreddit,
                        postType: redditDataController.postType,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Search Bar
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 800),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFd41132).withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFd41132).withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      offset: Offset.zero,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 24),
                                      child: Icon(Icons.search, color: Color(0xFFd41132), size: 28),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        decoration: const InputDecoration(
                                          hintText: 'Search topics',
                                          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (searchController.text.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          searchController.clear();
                                          load();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Sort Buttons
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: _buildSortButton(RedditPostType.values[0])),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildSortButton(RedditPostType.values[1])),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: _buildSortButton(RedditPostType.values[2])),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildSortButton(RedditPostType.values[3])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Results Count
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${redditDataController.postType.title} articles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          switch (state) {
                            Reddit$InitialState() => const SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            ),
                            Reddit$LoadingState() => const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator.adaptive()),
                            ),
                            Reddit$ErrorState() => SliverFillRemaining(
                              child: Center(child: error_widget.ErrorWidget(onRetry: load)),
                            ),
                            Reddit$LoadedState() =>
                              state.posts.isEmpty
                                  ? const SliverFillRemaining(child: Center(child: EmptyWidget()))
                                  : SliverGrid.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 24,
                                        mainAxisExtent: 320,
                                      ),
                                      itemCount: state.posts.length,
                                      itemBuilder: (context, index) {
                                        final post = state.posts[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ArticleConfigWidget(
                                                  postId: post.id,
                                                  key: ValueKey(post.id),
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildPostCard(post, index),
                                        );
                                      },
                                    ),
                          },

                          if (state is Reddit$LoadedState && state.hasMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator.adaptive()),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );

  Widget _buildSortButton(RedditPostType postType) => ElevatedButton(
    onPressed: () {
      redditDataController.setPostType(postType);
      redditController.load(
        redditDataController.subreddit,
        postType: redditDataController.postType,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: postType == redditDataController.postType
          ? const Color(0xFFd41132)
          : Colors.grey[900],
      foregroundColor: postType == redditDataController.postType ? Colors.white : Colors.grey[400],
      side: postType == redditDataController.postType
          ? null
          : BorderSide(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
    child: Text(
      postType.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: postType == redditDataController.postType ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );

  Widget _buildPostCard(RedditPost post, int index) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.grey[900]?.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFd41132).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'HALL OF FAME',
                  style: TextStyle(
                    color: Color(0xFFd41132),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'u/${post.author ?? "Anonymous"}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFd41132),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    Flexible(
                      child: Text(
                        'r/${post.subreddit ?? "nosleep"}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    post.selftext ?? 'No description available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFd41132).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.masks, color: Color(0xFFd41132), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${(post.score ?? 0).toInt()} SPOOKS',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFd41132),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        '${post.numComments ?? 0}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFd41132), size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}
