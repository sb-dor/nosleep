import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:no_sleep/src/common/widget/empty_widget.dart';
import 'package:no_sleep/src/common/widget/error_widget.dart' as error_widget;
import 'package:no_sleep/src/feature/github_reports/widgets/github_reports_config_widget.dart';
import 'package:no_sleep/src/feature/notifications/widgets/notifications_config_widget.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/logic/reddit_routing_handler.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_state_mixin.dart';

class RedditDesktopWidget extends StatefulWidget {
  const RedditDesktopWidget({super.key});

  @override
  State<RedditDesktopWidget> createState() => _RedditDesktopWidgetState();
}

class _RedditDesktopWidgetState extends State<RedditDesktopWidget> with RedditStateMixin {
  late final DesktopRedditRouting _desktopRedditRouting;

  @override
  void initState() {
    super.initState();
    _desktopRedditRouting = DesktopRedditRouting(redditStateMixin: this)..findModule(context);
  }

  @override
  Widget build(BuildContext context) => StateConsumer<RedditController, RedditState>(
    controller: redditController,
    builder: (context, state, child) => Scaffold(
      body: Row(
        children: [
          // Sidebar
          ListenableBuilder(
            listenable: redditDataController,
            builder: (context, child) {
              return SizedBox(
                width: 350,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0xFF0a0505)),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.skull, color: Color(0xFFd41132)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  redditDataController.subreddit,
                                  style: const TextStyle(
                                    color: Color(0xFFd41132),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Color(0xFFd41132),
                                  size: 28,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsConfigWidget(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.error_outline, color: Color(0xFFd41132)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const GithubReportsConfigWidget(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Search Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                      hintText: 'Search topics',
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
                                      setState(() {
                                        searchController.clear();
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Sort Buttons
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            mainAxisExtent: 40,
                          ),
                          itemCount: RedditPostType.values.length,
                          itemBuilder: (context, index) {
                            final postType = RedditPostType.values[index];
                            return _buildSortButton(postType);
                          },
                        ),
                      ),

                      // Popular Subreddits
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
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
                              IconButton(
                                onPressed: () => load(reload: true),
                                icon: const Icon(Icons.refresh),
                              ),
                            ],
                          ),
                        ),
                      ),

                      switch (state) {
                        Reddit$InitialState() => const SliverToBoxAdapter(child: SizedBox.shrink()),
                        Reddit$LoadingState() => const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        ),
                        Reddit$ErrorState() => SliverFillRemaining(
                          child: Center(
                            child: error_widget.ErrorWidget(onRetry: () => load(reload: true)),
                          ),
                        ),
                        Reddit$LoadedState() =>
                          state.posts.isEmpty
                              ? const SliverFillRemaining(child: EmptyWidget())
                              : SliverFixedExtentList.builder(
                                  itemExtent: 110,
                                  itemCount: state.posts.length,
                                  itemBuilder: (context, index) {
                                    final post = state.posts[index];
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          _desktopRedditRouting.navigateTo(context, post.id);
                                        },
                                        child: _buildSidebarPostItem(post, index),
                                      ),
                                    );
                                  },
                                ),
                      },

                      if (state is Reddit$LoadedState && state.hasMore)
                        const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          ListenableBuilder(
            listenable: redditDataController,
            child: const Expanded(
              child: Center(
                child: Text('Start to read articles clicking on any article from left sidebar'),
              ),
            ),
            builder: (context, child) {
              if (redditDataController.desktopSelectedArticle != null) {
                return Expanded(child: redditDataController.desktopSelectedArticle!);
              } else {
                return child!;
              }
            },
          ),
        ],
      ),
    ),
  );

  Widget _buildSortButton(final RedditPostType postType) => SizedBox(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: postType == redditDataController.postType
                ? Colors.transparent
                : const Color(0xFFd41132).withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildSidebarPostItem(RedditPost post, int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[900]?.withValues(alpha: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          post.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFd41132).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFd41132).withValues(alpha: 0.3)),
              ),
              child: Text(
                'r/${post.subreddit ?? "unknown"}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFd41132),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.masks, color: Color(0xFFd41132), size: 12),
                const SizedBox(width: 4),
                Text(
                  '${(post.score ?? 0).toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
