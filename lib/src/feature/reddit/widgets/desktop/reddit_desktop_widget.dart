import 'package:flutter/material.dart';
import 'package:no_sleep/src/feature/reddit/controller/reddit_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/controllers/reddit_data_controller.dart';
import 'package:no_sleep/src/feature/reddit/widgets/reddit_config_widget.dart';

class RedditDesktopWidget extends StatefulWidget {
  const RedditDesktopWidget({super.key});

  @override
  State<RedditDesktopWidget> createState() => _RedditDesktopWidgetState();
}

class _RedditDesktopWidgetState extends State<RedditDesktopWidget> {
  late final _redditInhWidget = RedditConfigInhWidget.of(context);
  late final redditController = _redditInhWidget.redditController;
  late final redditDataController = _redditInhWidget.redditDataController;

  @override
  void initState() {
    super.initState();
    // Load default subreddit on init
    redditController.loadPosts('popular');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Reddit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Sidebar for subreddit selection
          SizedBox(
            width: 250,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Subreddit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
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
                    const SizedBox(height: 16),
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
                                      redditDataController.setSelectedSubreddit(
                                        textEditingController.text,
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Load'),
                                ),
                              ],
                            ),
                        );
                      },
                      child: const Text('Load Subreddit'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Popular Subreddits',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Popular'),
                      onTap: () {
                        redditController.loadPosts('popular');
                        redditDataController.setSelectedSubreddit('popular');
                      },
                    ),
                    ListTile(
                      title: const Text('AskReddit'),
                      onTap: () {
                        redditController.loadPosts('AskReddit');
                        redditDataController.setSelectedSubreddit('AskReddit');
                      },
                    ),
                    ListTile(
                      title: const Text('WorldNews'),
                      onTap: () {
                        redditController.loadPosts('worldnews');
                        redditDataController.setSelectedSubreddit('worldnews');
                      },
                    ),
                    ListTile(
                      title: const Text('Technology'),
                      onTap: () {
                        redditController.loadPosts('technology');
                        redditDataController.setSelectedSubreddit('technology');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Main content area for posts
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      return ElevatedButton(onPressed: () {}, child: const Icon(Icons.refresh));
                    case Reddit$LoadedState():
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                // Show comments for this post
                                redditController.loadComments(
                                  redditDataController.selectedSubreddit ?? 'popular',
                                  post.id,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'by ${post.author ?? "unknown"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${post.score ?? 0} upvotes | ${post.numComments ?? 0} comments',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    if (post.selftext != null && post.selftext!.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          post.selftext!,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
}
