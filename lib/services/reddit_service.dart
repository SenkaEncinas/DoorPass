import 'dart:convert';
import 'package:doorpass/models/Entities/RedditDto.dart';
import 'package:http/http.dart' as http;

class RedditService {
  final String _proxyUrl = 'https://corsproxy.io/?';
  final String _baseUrl = 'https://www.reddit.com';
  final String _userAgent = 'DoorpassApp/1.0.0';

  Future<List<RedditDto>> getDoorpassPosts() async {
    try {
      print('🔍 Obteniendo posts de r/doorpass...');
      
      final response = await http.get(
        Uri.parse('$_proxyUrl${Uri.encodeFull('$_baseUrl/r/doorpass/hot.json?limit=20')}'),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        print('✅ Posts de r/doorpass obtenidos exitosamente');
        return _parsePosts(response.body);
      } else {
        print('❌ Error obteniendo r/doorpass: ${response.statusCode}');
        return _getMockPosts();
      }
    } catch (e) {
      print('❌ Error en getDoorpassCommunityPosts: $e');
      return _getMockPosts();
    }
  }

  List<RedditDto> _parsePosts(String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      final List<dynamic> postsData = data['data']['children'];
      
      List<RedditDto> posts = [];

      for (var postData in postsData) {
        final Map<String, dynamic> post = postData['data'];
        
        final redditPost = RedditDto(
          // Información básica
          title: post['title'] ?? 'Sin título',
          upvotes: post['score'] ?? 0,
          comments: post['num_comments'] ?? 0,
          subreddit: post['subreddit'] ?? '',
          author: post['author'] ?? '',
          created: DateTime.fromMillisecondsSinceEpoch(
            (post['created_utc'] ?? 0) * 1000,
          ),
          url: 'https://reddit.com${post['permalink']}',
          
          // Información adicional
          selftext: post['selftext'] ?? '',
          thumbnail: post['thumbnail'] ?? '',
          fullImageUrl: post['url_overridden_by_dest'] ?? '',
          isSelfPost: post['is_self'] ?? false,
          upvoteRatio: post['upvote_ratio'] ?? 0.0,
          totalAwards: post['total_awards_received'] ?? 0,
          isVideo: post['is_video'] ?? false,
          isNsfw: post['over_18'] ?? false,
          isSpoiler: post['spoiler'] ?? false,
          isStickied: post['stickied'] ?? false,
          flair: post['link_flair_text'] ?? '',
        );
        
        posts.add(redditPost);
      }

      return posts;
    } catch (e) {
      print('Error parseando posts: $e');
      return _getMockPosts();
    }
  }

  List<RedditDto> _getMockPosts() {
    return [
      RedditDto(
        title: 'Primer post en la comunidad Doorpass',
        upvotes: 15,
        comments: 3,
        subreddit: 'doorpass',
        author: 'Sea_Assumption_464',
        created: DateTime.now().subtract(Duration(minutes: 5)),
        url: 'https://reddit.com/r/doorpass/mock1',
        selftext: 'Aquí va el primer post para la pagina de doorpass. Bienvenidos todos a nuestra comunidad oficial.',
        thumbnail: '',
        fullImageUrl: '',
        isSelfPost: true,
        upvoteRatio: 0.95,
        totalAwards: 0,
        isVideo: false,
        isNsfw: false,
        isSpoiler: false,
        isStickied: false,
        flair: 'Anuncio',
      ),
      RedditDto(
        title: 'Nuevos eventos esta semana - No se lo pierdan!',
        upvotes: 42,
        comments: 12,
        subreddit: 'doorpass',
        author: 'doorpass_admin',
        created: DateTime.now().subtract(Duration(hours: 2)),
        url: 'https://reddit.com/r/doorpass/mock2',
        selftext: 'Tenemos eventos increíbles preparados para este fin de semana. DJs internacionales y promociones especiales.',
        thumbnail: '',
        fullImageUrl: '',
        isSelfPost: true,
        upvoteRatio: 0.88,
        totalAwards: 2,
        isVideo: false,
        isNsfw: false,
        isSpoiler: false,
        isStickied: true,
        flair: 'Evento',
      ),
      RedditDto(
        title: 'Sistema de manillas digitales ahora disponible',
        upvotes: 28,
        comments: 7,
        subreddit: 'doorpass',
        author: 'tech_manager',
        created: DateTime.now().subtract(Duration(hours: 6)),
        url: 'https://reddit.com/r/doorpass/mock3',
        selftext: 'Ya pueden usar nuestras manillas digitales desde la app. Más fácil y seguro para todos.',
        thumbnail: '',
        fullImageUrl: '',
        isSelfPost: true,
        upvoteRatio: 0.92,
        totalAwards: 1,
        isVideo: false,
        isNsfw: false,
        isSpoiler: false,
        isStickied: false,
        flair: 'Tecnología',
      ),
    ];
  }
}