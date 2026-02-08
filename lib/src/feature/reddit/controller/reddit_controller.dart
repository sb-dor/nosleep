import 'package:control/Control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:no_sleep/src/common/util/local_pagination_util.dart';
import 'package:no_sleep/src/feature/reddit/data/reddit_repository.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post.dart';
import 'package:no_sleep/src/feature/reddit/models/reddit_post_type.dart';

part 'reddit_controller.freezed.dart';

@freezed
sealed class RedditState with _$RedditState {
  const factory RedditState.initial() = Reddit$InitialState;

  const factory RedditState.loading() = Reddit$LoadingState;

  const factory RedditState.error({final String? message}) = Reddit$ErrorState;

  const factory RedditState.loaded({
    required final List<RedditPost> posts,
    required final bool hasMore,
    required final String? nextPage,
  }) = Reddit$LoadedState;
}

final class RedditController extends StateController<RedditState> with SequentialControllerHandler {
  RedditController({
    required final IRedditRepository redditRepository,
    required final LocalPaginationUtil localPaginationUtil,
    super.initialState = const RedditState.initial(),
  }) : _redditRepository = redditRepository,
       _localPaginationUtil = localPaginationUtil;

  final IRedditRepository _redditRepository;
  final LocalPaginationUtil _localPaginationUtil;

  Future<void> load(
    final String subreddit, {
    final RedditPostType postType = RedditPostType.newest,
    final int limit = 10,
    final bool reload = false,
  }) => handle(() async {
    if (state is Reddit$LoadedState && !reload) return;

    setState(const RedditState.loading());

    final data = await _redditRepository.getPosts(subreddit, limit: limit, postType: postType);

    final hasMore = _localPaginationUtil.checkIsListHasMorePageBool(
      list: data.posts,
      limitInPage: limit,
    );

    setState(RedditState.loaded(posts: data.posts, hasMore: hasMore, nextPage: data.nextPage));
  }, error: (error, stackTrace) async => setState(const RedditState.error()));

  Future<void> paginate(
    final String subreddit, {
    final RedditPostType postType = RedditPostType.newest,
    final int limit = 10,
  }) => handle(() async {
    if (state is! Reddit$LoadedState) return;

    final currentState = state as Reddit$LoadedState;

    if (!currentState.hasMore) return;

    final currentList = List.of(currentState.posts);

    final data = await _redditRepository.getPosts(
      subreddit,
      limit: limit,
      nextPage: currentState.nextPage,
      postType: postType,
    );

    final hasMore = _localPaginationUtil.checkIsListHasMorePageBool(
      list: data.posts,
      limitInPage: limit,
    );

    currentList.addAll(data.posts);

    setState(RedditState.loaded(posts: currentList, hasMore: hasMore, nextPage: data.nextPage));
  }, error: (error, stackTrace) async => setState(const RedditState.error()));
}
