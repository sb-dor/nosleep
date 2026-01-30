enum RedditPostType {
  newest._('Newest', 'new'),
  topRated._('Top rated', 'top'),
  controversial._('Controversial', 'controversial'),
  hot._('Hot', 'hot');

  const RedditPostType._(this.title, this.key);

  final String title;
  final String key;
}
