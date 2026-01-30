import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/common/widget/empty_widget.dart';
import 'package:no_sleep/src/common/widget/error_widget.dart' as error_widget;
import 'package:no_sleep/src/feature/article/widgets/article_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_state_mixin.dart';

class RedditMobileWidget extends StatefulWidget {
  const RedditMobileWidget({super.key});

  @override
  State<RedditMobileWidget> createState() => _RedditMobileWidgetState();
}

class _RedditMobileWidgetState extends State<RedditMobileWidget> with RedditStateMixin {
  @override
  Widget build(BuildContext context) => StateConsumer<RedditController, RedditState>(
    controller: redditController,
    builder: (context, state, child) {
      // Show the list of posts
      return ListenableBuilder(
        listenable: redditDataController,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title:  Row(
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
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
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
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Search Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFd41132).withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFd41132).withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Icon(Icons.search, color: Color(0xFFd41132)),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        hintText: 'Search subreddits',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.grey),
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
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverGrid.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 45,
                            ),
                            itemCount: RedditPostType.values.length,
                            itemBuilder: (context, index) {
                              final postType = RedditPostType.values[index];
                              return _buildSortButton(postType);
                            },
                          ),
                        ),

                        // Results Count
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              '${redditDataController.postType.title} articles',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                letterSpacing: 1.5,
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
                                ? const SliverFillRemaining(child: EmptyWidget())
                                : SliverList.builder(
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
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );

  Widget _buildSortButton(RedditPostType postType) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
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
        foregroundColor: postType == redditDataController.postType
            ? Colors.white
            : Colors.grey[400],
        side: postType == redditDataController.postType
            ? null
            : BorderSide(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        postType.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: postType == redditDataController.postType
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    ),
  );

  Widget _buildPostCard(RedditPost post, int index) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41132).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'HALL OF FAME',
                        style: TextStyle(
                          color: Color(0xFFd41132),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'u/${post.author ?? "Anonymous"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFd41132),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                    Text(
                      'r/${post.subreddit ?? "nosleep"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.selftext ?? 'No description available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFd41132).withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFd41132).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.masks, color: Color(0xFFd41132), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${(post.score ?? 0).toInt()} SPOOKS',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFd41132),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${post.numComments ?? 0}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFd41132), size: 16),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
