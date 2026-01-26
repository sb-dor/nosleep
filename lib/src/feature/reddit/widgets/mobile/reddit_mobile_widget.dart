import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

class RedditMobileWidget extends StatefulWidget {
  const RedditMobileWidget({super.key});

  @override
  State<RedditMobileWidget> createState() => _RedditMobileWidgetState();
}

class _RedditMobileWidgetState extends State<RedditMobileWidget> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;

  @override
  void initState() {
    super.initState();
    redditController.loadPosts('popular');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Reddit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter subreddit name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        redditController.loadPosts(value);
                        redditDataController.setSelectedSubreddit(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final textEditingController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Enter Subreddit'),
                        content: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., funny, worldnews',
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              redditController.loadPosts(value);
                              redditDataController.setSelectedSubreddit(value);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (textEditingController.text.isNotEmpty) {
                                redditController.loadPosts(textEditingController.text);
                                redditDataController.setSelectedSubreddit(textEditingController.text);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('Load'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: redditController,
              builder: (context, child) {
                final state = redditController.state;

                switch (state) {
                  case Reddit$InitialState():
                    return const SizedBox.shrink();
                  case Reddit$LoadingState():
                    return const Center(child: CircularProgressIndicator());
                  case Reddit$ErrorState():
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          ElevatedButton(
                            onPressed: () {
                              final subreddit = redditDataController.selectedSubreddit ?? 'popular';
                              redditController.loadPosts(subreddit);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  case Reddit$LoadedState():
                    return ListView.builder(
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(post.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'by ${post.author ?? "unknown"} | ${post.score ?? 0} upvotes | ${post.numComments ?? 0} comments',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (post.selftext != null && post.selftext!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      post.selftext!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Show comments for this post
                              redditController.loadComments(
                                redditDataController.selectedSubreddit ?? 'popular',
                                post.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
}
