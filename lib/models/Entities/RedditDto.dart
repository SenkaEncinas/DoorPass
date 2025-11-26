class RedditDto {
  // Información básica
  final String title;
  final int upvotes;
  final int comments;
  final String subreddit;
  final String author;
  final DateTime created;
  final String url;

  // Información adicional
  final String selftext;
  final String thumbnail;
  final String fullImageUrl;
  final bool isSelfPost;
  final double upvoteRatio;
  final int totalAwards;
  final bool isVideo;
  final bool isNsfw;
  final bool isSpoiler;
  final bool isStickied;
  final String flair; // Etiqueta del post

  RedditDto({
    // Básico
    required this.title,
    required this.upvotes,
    required this.comments,
    required this.subreddit,
    required this.author,
    required this.created,
    required this.url,

    // Adicional
    required this.selftext,
    required this.thumbnail,
    required this.fullImageUrl,
    required this.isSelfPost,
    required this.upvoteRatio,
    required this.totalAwards,
    required this.isVideo,
    required this.isNsfw,
    required this.isSpoiler,
    required this.isStickied,
    required this.flair,
  });

  factory RedditDto.fromJson(Map<String, dynamic> json) {
    return RedditDto(
      // Información básica
      title: json['title'] ?? 'Sin título',
      upvotes: json['score'] ?? 0,
      comments: json['num_comments'] ?? 0,
      subreddit: json['subreddit'] ?? '',
      author: json['author'] ?? '',
      created: DateTime.fromMillisecondsSinceEpoch(
        (json['created_utc'] ?? 0) * 1000,
      ),
      url: 'https://reddit.com${json['permalink']}',

      // Información adicional
      selftext: json['selftext'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      fullImageUrl: json['url_overridden_by_dest'] ?? '',
      isSelfPost: json['is_self'] ?? false,
      upvoteRatio: json['upvote_ratio'] ?? 0.0,
      totalAwards: json['total_awards_received'] ?? 0,
      isVideo: json['is_video'] ?? false,
      isNsfw: json['over_18'] ?? false,
      isSpoiler: json['spoiler'] ?? false,
      isStickied: json['stickied'] ?? false,
      flair: json['link_flair_text'] ?? '',
    );
  }
}